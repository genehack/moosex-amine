package Moosescope;

use Moose;

use Modern::Perl;
use PPI::Document;
use Try::Tiny;

has 'metaobj' => (
  is => 'ro' ,
  isa => 'Moose::Meta::Class' ,
  lazy => 1 ,
  builder => '_build_metaobj'
);

sub _build_metaobj {
  my $self = shift;
  return $self->{module}->meta;
}

has 'module'  => ( is => 'ro' , isa => 'Str' );
has 'path'    => ( is => 'ro' , isa => 'Str' );

sub BUILDARGS {
  my $class = shift;

  my %args;
  if ( @_ == 1 ) {
    if ( !ref $_[0] ) { %args = ( module => $_[0] ) }
    else {%args = %{$_[0]} }
  }
  else {%args = @_; }

  eval "require $args{module};";
  die $@ if $@;

  my $path = $args{module} . '.pm';
  $path =~ s|::|/|g;
  $args{path} = $INC{$path};

  return \%args;
}

sub examine {
  my( $self ) = shift;
  my $meta = $self->metaobj;

  my( %return );

  foreach my $metaattr ( $meta->get_all_attributes ) {
    my $name = $metaattr->name;
    $return{attrs}{$name} = _examine_attr( $metaattr );
  }

  foreach my $metamethod ( $meta->get_all_methods ) {
    my $src = $metamethod->original_package_name;
    next if $src =~ /^Moose/;

    my $name = $metamethod->name;
    next if _check_exclude( $name );

    my @stock = qw/ DESTROY meta new /;
    next if $name ~~ @stock;

    $return{methods}{ $metamethod->name } = {
      from => $metamethod->original_package_name
    }
  }

  return \%return;
}

{
  my $excludes;
  sub _add_exclusion { my $fxn = shift; $excludes->{$fxn}++ }
  sub _check_exclude { my $fxn = shift; return $excludes->{$fxn} }
}

sub _examine_attr {
  my $metaattr = shift;

  my $return = { from => $metaattr->associated_class->name };

  foreach ( qw/ reader writer accessor / ) {
    next unless my $fxn = $metaattr->$_;
    _add_exclusion( $fxn );
    $return->{$_} = $fxn;
  }

  $return->{meta}{documentation} = $metaattr->documentation
    if ( $metaattr->has_documentation );

  $return->{meta}{constraint} = $metaattr->type_constraint->name
    if ( $metaattr->has_type_constraint );

  foreach ( qw/
                is_weak_ref is_required is_lazy is_lazy_build should_coerce
                should_auto_deref has_trigger has_handles
              / ) {
    $return->{meta}{$_}++ if $metaattr->$_ ;
  }

  return $return;

}

__PACKAGE__->meta->make_immutable;
1;

