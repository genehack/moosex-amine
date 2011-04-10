package MooseX::amine;
# ABSTRACT: Examine Yr Moose

use Moose;
use Moose::Meta::Class;
use Moose::Meta::Role;
use Moose::Util::TypeConstraints;

use Modern::Perl;
use Test::Deep::NoTest qw/eq_deeply/;
use Try::Tiny;

has 'metaobj' => (
  is      => 'ro' ,
  isa     => 'Object' ,
  lazy    => 1 ,
  builder => '_build_metaobj' ,
);

sub _build_metaobj {
  my $self = shift;
  return $self->{module}->meta
    or die "Can't get meta object for module!" ;
}

has 'module' => ( is => 'ro' , isa => 'Str' );
has 'path'   => ( is => 'ro' , isa => 'Str' );

has 'attributes' => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ 'Hash' ] ,
  handles => {
    get_attribute              => 'get' ,
    store_attribute            => 'set' ,
    check_for_stored_attribute => 'exists' ,
  },
);

has 'exclusions' => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  handles => {
    add_exclusion   => sub { my( $self , $ex ) = @_; $self->{exclusions}{$ex}++ } ,
    check_exclusion => sub { my( $self , $ex ) = @_; return $self->{exclusions}{$ex} } ,
  }
);

has 'methods' => (
  is      => 'ro' ,
  isa     => 'HashRef' ,
  traits  => [ 'Hash' ] ,
  handles => {
    store_method => 'set' ,
  },
);

sub BUILDARGS {
  my $class = shift;

  my $args = _convert_to_hashref_if_needed( @_ );

  eval "require $args->{module};";
  die $@ if $@;

  my $path = $args->{module} . '.pm';
  $path =~ s|::|/|g;
  $args->{path} = $INC{$path};

  return $args;
}

sub dissect_attribute {
  my( $self , $meta , $attribute_name ) = @_;

  my $meta_attr = $meta->get_attribute( $attribute_name );

  my $return;
  given ( ref $meta_attr ) {
    when( 'Moose::Meta::Attribute' ) {
      $return = $meta_attr->associated_class->name;
    }
    when( 'Moose::Meta::Role::Attribute' ) {
      $return = $meta_attr->original_role->name;
      $meta_attr = $meta_attr->attribute_for_class();
    }
    default { die "can't handle $_" }
  }

  my $extracted_attribute = $self->extract_attribute_metainfo( $meta_attr );
  $extracted_attribute->{from} = $return;

  if ( $self->check_for_stored_attribute( $attribute_name )) {
    $extracted_attribute = _compare_attrs(
      $extracted_attribute , $self->get_attribute( $attribute_name )
    );
  }

  $self->store_attribute( $attribute_name => $extracted_attribute );
}

sub dissect_class {
  my( $self , $class ) = @_;
  my $meta = $class->meta;

  if ( $meta->can( 'roles' )) {
    foreach my $role ( @{ $meta->roles } ) {
      $self->dissect_role( $role );
    }
  }

  foreach my $attr ( $meta->get_attribute_list ) {
    $self->dissect_attribute( $meta , $attr );
  }

  foreach my $method ( $meta->get_method_list ) {
    $self->dissect_method( $meta , $method );
  }
}

sub dissect_method {
  my( $self , $meta , $method_name ) = @_;

  my $meta_method = $meta->get_method( $method_name );
  my $src = $meta_method->original_package_name;

  ### FIXME this should also be a config option, i guess...
  return if $self->check_exclusion( $method_name );

  ### FIXME this should be controlled by a flag too
  my @stock = qw/ DESTROY meta new /;
  return if $method_name ~~ @stock;

  my $extracted_method =  $self->extract_method_metainfo( $meta_method );
  $self->store_method( $method_name => $extracted_method );
}

sub dissect_role {
  my( $self , $meta ) = @_;

  map { $self->dissect_attribute( $meta , $_ ) } $meta->get_attribute_list;
  map { $self->dissect_method( $meta , $_ )    } $meta->get_method_list;

}

sub examine {
  my $self = shift;
  my $meta = $self->metaobj;

  if ( $meta->isa( 'Moose::Meta::Role' )) {
    $self->dissect_role( $meta );
  }
  else {
    foreach my $class ( reverse $meta->linearized_isa ) {
      # FIXME should be a config option
      next if $class =~ /^Moose/;
      $self->dissect_class( $class );
    }
  }

  return {
    attrs   => $self->{attributes} ,
    methods => $self->{methods} ,
  }
}

sub extract_attribute_metainfo {
  my( $self , $meta_attr ) = @_;

  my $return = {};

  foreach ( qw/ reader writer accessor / ) {
    next unless my $fxn = $meta_attr->$_;
    $self->add_exclusion( $fxn );
    $return->{$_} = $fxn;
  }

  $return->{meta}{documentation} = $meta_attr->documentation
    if ( $meta_attr->has_documentation );

  $return->{meta}{constraint} = $meta_attr->type_constraint->name
    if ( $meta_attr->has_type_constraint );

  foreach ( qw/
                is_weak_ref is_required is_lazy is_lazy_build should_coerce
                should_auto_deref has_trigger has_handles
              / ) {
    $return->{meta}{$_}++ if $meta_attr->$_ ;
  }

  return $return;

}

sub extract_method_metainfo {
  my( $self , $meta_method ) = @_;

  return {
    from => $meta_method->original_package_name ,
  };
}

sub _compare_attrs {
  my( $new_attr , $old_attr ) = @_;

  my $new_from = delete $new_attr->{from};
  my $old_from = delete $old_attr->{from};

  if ( eq_deeply( $new_attr , $old_attr )) {
    $old_attr->{from} = $old_from;
    return $old_attr;
  } else {
    $new_attr->{from} = $new_from;
    return $new_attr;
  }
}

sub _convert_to_hashref_if_needed {
  my( @list_of_args ) = @_;

  return $_[0] if ref $_[0];

  return { module => $_[0] } if @_ == 1;

  my %hash = @_;
  return \%hash;
}

__PACKAGE__->meta->make_immutable;
1;

