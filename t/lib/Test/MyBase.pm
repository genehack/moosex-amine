package Test::MyBase;
use Moose;
with 'Test::MyBaseRole','Test::MyCommonRole';

has 'base_string_attribute' => ( is => 'ro' , isa => 'Str' );
has 'overloaded_attribute'  => ( is => 'ro' , isa => 'Str' );

sub base_test_method  { return 'this is a test from the base' }
sub overloaded_method { return 'this is the base' }

__PACKAGE__->meta->make_immutable;
1;
