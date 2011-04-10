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

sub examine {
  my $self = shift;
  my $meta = $self->metaobj;

  my %return;

  if ( $meta->can( 'roles' )) {
    foreach my $role ( @{ $meta->roles } ) {
      foreach my $attr( $role->get_attribute_list ) {
        my $meta_attr = $role->get_attribute( $attr );
        $return{attrs}{$attr} = _dissect_attr( $meta_attr );
      }
    }
  }

  foreach my $attr ( $meta->get_attribute_list ) {
    my $meta_attr = $meta->get_attribute( $attr );

    my $dissected_attr = _dissect_attr( $meta_attr );

    $return{attrs}{$attr} = ( $return{attrs}{$attr} ) ?
      _compare_attrs( $dissected_attr , $return{attrs}{$attr} ) : $dissected_attr;
  }

  foreach my $method ( $meta->get_method_list ) {
    my $meta_method = $meta->get_method( $method );
    my $src = $meta_method->original_package_name;

    ### FIXME this should be controlled by a flag
    next if $src =~ /^Moose/;

    ### FIXME this should also be a config option, i guess...
    next if _check_exclude( $method );

    ### FIXME this should be controlled by a flag too
    my @stock = qw/ DESTROY meta new /;
    next if $method ~~ @stock;

    $return{methods}{$method} = _dissect_method( $meta_method );
  }

  return \%return;
}

{
  my $excludes;
  sub _add_exclusion { my $name = shift; $excludes->{$name}++ }
  sub _check_exclude { my $name = shift; return $excludes->{$name} }
}

sub _compare_attrs {
  my( $new_attr , $old_attr ) = @_;

  my $new_from = delete $new_attr->{from};
  my $old_from = delete $old_attr->{from};

  if ( eq_deeply( $new_attr , $old_attr )) {
    $old_attr->{from} = $old_from;
    return $old_attr;
  }
  else {
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

sub _dissect_attr {
  my $meta_attr = shift;

  my $return;
  given ( ref $meta_attr ) {
    when( 'Moose::Meta::Attribute' ) {
      $return = { from => $meta_attr->associated_class->name };
    }
    when( 'Moose::Meta::Role::Attribute' ) {
      $return = { from => $meta_attr->original_role->name };
    }
    default { die "can't handle $_" }
  }

  $meta_attr = $meta_attr->attribute_for_class()
    if ( $meta_attr->isa( 'Moose::Meta::Role::Attribute' ));

  foreach ( qw/ reader writer accessor / ) {
    next unless my $fxn = $meta_attr->$_;
    _add_exclusion( $fxn );
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

sub _dissect_method {
  my $meta_method = shift;

  return {
    from => $meta_method->original_package_name ,
  };
}

__PACKAGE__->meta->make_immutable;
1;

