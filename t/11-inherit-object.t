#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Inheritance::Object' );

isa_ok( $mex , 'MooseX::amine' );
isa_ok( $mex->metaobj , 'Moose::Meta::Class' );

my $expected_data_structure = {
  attrs   => {
    base_attribute   => {
      from   => 'Test::Inheritance::Base',
      meta   => { constraint => 'Str' },
      reader => 'base_attribute'
    },
    string_attribute => {
      accessor => 'string_attribute',
      from     => 'Test::Inheritance::Object',
      meta     => { constraint => 'Str' }
    }
  },
  methods => {
    base_method => { from => 'Test::Inheritance::Base' },
    test_method => { from => 'Test::Inheritance::Object' }
  }
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();
