#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Basic::Object' );

isa_ok( $mex , 'MooseX::amine' );
isa_ok( $mex->metaobj , 'Moose::Meta::Class' );

my $expected_data_structure = {
  attrs => {
    simple_attribute => {
      accessor => 'simple_attribute',
      from     => 'Test::Basic::Object',
      meta     => {
        constraint => 'Str' ,
      } ,
    } ,
  },
  methods => {
    simple_method => {
      from => 'Test::Basic::Object' ,
    } ,
  } ,
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();