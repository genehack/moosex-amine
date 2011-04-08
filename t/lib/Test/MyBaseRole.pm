package Test::MyBaseRole;
use Moose::Role;

has 'base_role_attribute' => ( is => 'ro' , isa => 'Str' );

sub base_role_method { return 'this is the role' }

1;
