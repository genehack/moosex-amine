#! perl

use Test::More;

use_ok 'Moosescope';

my $m = Moosescope->new( 'Test::MyObject' );

isa_ok( $m , 'Moosescope' );
isa_ok( $m->metaobj , 'Moose::Meta::Class' );

use Data::Dump::Streamer;
diag Dump $m->examine();

#is_deeply( [ $m->metaobj->get_method_list ] , [ 'meta' , 'new' , 'DESTROY' , 'test_method', 'string_attribute' ] , 'see expected methods' );

done_testing();
