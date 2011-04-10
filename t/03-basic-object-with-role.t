#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Basic::ObjectWithRole' );

isa_ok( $mex , 'MooseX::amine' );
isa_ok( $mex->metaobj , 'Moose::Meta::Class' );

my $expected_data_structure = {
  attrs => {
    role_attribute => {
      accessor => 'role_attribute',
      from     => 'Test::Basic::Role',
      meta     => {
        constraint    => 'Str' ,
        is_required   => 1 ,
        documentation => 'required string' ,
      } ,
    } ,
    simple_ro_attribute => {
      reader   => 'simple_ro_attribute',
      from     => 'Test::Basic::ObjectWithRole',
      meta     => {
        constraint => 'Str' ,
      } ,
    } ,
  },
  methods => {
    role_method => {
      from => 'Test::Basic::Role' ,
    } ,
    simple_method => {
      from => 'Test::Basic::ObjectWithRole' ,
    } ,
  } ,
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();
