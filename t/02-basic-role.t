#! perl

use Test::More;

use MooseX::amine;
use lib './t/lib';

my $mex = MooseX::amine->new( 'Test::Basic::Role' );

isa_ok( $mex , 'MooseX::amine' );
isa_ok( $mex->metaobj , 'Moose::Meta::Role' );

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
  },
  methods => {
    role_method => {
      from => 'Test::Basic::Role' ,
    } ,
  } ,
};
is_deeply( $mex->examine , $expected_data_structure , 'see expected output from examine()' );

done_testing();
