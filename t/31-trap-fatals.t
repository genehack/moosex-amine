#! perl

use Test::More;
use Test::Trap qw/ trap $trap :flow :stderr(systemsafe) /;
use Errno qw/ ENOENT /;

use MooseX::amine;
use lib './t/lib';

my @r = trap { MooseX::amine->new() };
is( $trap->leaveby, 'die', 'Empty constructor dies' );
like( $trap->die, qr/Need to provide 'module' or 'path'/,
  'Empty constructor error message' );

@r = trap { MooseX::amine->new( 'Foo::Bar::Baz' ) };
is( $trap->leaveby, 'die', 'Unfound module in constructor dies' );
like( $trap->die, qr/Can't locate Foo.Bar.Baz\.pm in \@INC/,
  'Unfound module in constructor error message' );

@r = trap { MooseX::amine->new({ path => 'foo/bar/baz.pm' }) };
is( $trap->leaveby, 'die', 'Unfound path in constructor dies' );
my $enoent_message = do { local $! = ENOENT; "$!" };
like( $trap->die, qr/\Q$enoent_message/,
  'Unfound path in constructor error message' );

@r = trap { MooseX::amine->new({ path => './t/lib/Test/Bad/Foo.pm' }) };
is( $trap->leaveby, 'die', 'Module/path mismatch in constructor dies' );
like( $trap->die, qr/Can't locate Bar\.pm in \@INC/,
  'Module/path mismatch in constructor error message' );

done_testing();
