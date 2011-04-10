#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Override::ObjectWithRole' );

isa_ok( $mex , 'MooseX::amine' );
isa_ok( $mex->metaobj , 'Moose::Meta::Class' );

my $expected_data_structure = {
  attrs   => {
    base_attribute   => {
      from     => 'Test::Override::ObjectWithRole',
      meta     => { constraint => 'Str' },
      accessor => 'base_attribute'
    },
    string_attribute => {
      accessor => 'string_attribute',
      from     => 'Test::Override::ObjectWithRole',
      meta     => { constraint => 'Str' }
    },
    role_attribute => {
      reader   => 'role_attribute',
      from     => 'Test::Override::ObjectWithRole',
      meta     => {
        constraint    => 'Int' ,
      } ,
    } ,
  },
  methods => {
    base_method => { from => 'Test::Override::ObjectWithRole' },
    test_method => { from => 'Test::Override::ObjectWithRole' },
    role_method => { from => 'Test::Override::ObjectWithRole' },
  }
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();
