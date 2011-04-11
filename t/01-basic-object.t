#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Basic::Object' );

isa_ok( $mex , 'MooseX::amine' );

my $expected_data_structure = {
  attributes => {
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
      code => qq|sub simple_method   { return 'simple' }| ,
    } ,
  } ,
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();
