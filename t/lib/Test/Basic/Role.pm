package Test::Basic::Role;
use Moose::Role;
has 'simple_attribute' => ( is => 'rw' , isa => 'Str' );
sub simple_method  { return 'simple' }
1;
