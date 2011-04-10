package Test::Basic::Object;
use Moose;
has 'simple_attribute' => ( is => 'rw' , isa => 'Str' );
sub simple_method  { return 'simple' }
__PACKAGE__->meta->make_immutable;
1;
