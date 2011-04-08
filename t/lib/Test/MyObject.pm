package Test::MyObject;
use Moose;
extends 'Test::MyBase';
with 'Test::MyRole', 'Test::MyCommonRole';

has 'string_attribute'      => ( is => 'rw' , isa => 'Str' );
has 'overloaded_attribute'  => ( is => 'ro' , isa => 'Str' );

sub test_method        { return 'this is a test' }
sub overloaded_method  { return 'this is the child' }

__PACKAGE__->meta->make_immutable;
1;
