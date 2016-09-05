use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  languages => %( perl => 'perl' ),
  output => 'hello',
);

lives-ok( { $otx.validate(q:to/HERE/) }, 'code block');

HELLO WORLD
code: <<FOO
!perl
  my $a=1;
  my $b=2;
  [$a,$b]
FOO
HERE

done-testing;
