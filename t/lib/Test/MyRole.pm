package Test::MyRole;
use Moose::Role;

has 'role_attribute' => ( is => 'ro' , isa => 'Str' );

sub role_method { return 'this is the role' }

1;
