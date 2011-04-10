package Test::Basic::Object;
use Moose;
has 'simple_attribute'   => ( is => 'rw' , isa => 'Str' );
has '_private_attribute' => ( is => 'ro' , isa => 'Int' );
sub simple_method   { return 'simple' }
sub _private_method { return 'private' }
__PACKAGE__->meta->make_immutable;
1;
