use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0
);

lives-ok( { $otx.validate(q:to/HERE/) }, 'code block here string');
HELLO WORLD
code: <<FOO
!perl
  $a=1;
  $b=2;
  [$a,$b]
FOO
regexp: \d OK
hello world
HERE

$otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
);

lives-ok( { $otx.validate(q:to/HERE/) }, 'code block slash dot');
HELLO WORLD
code:         \
!perl         \
$a = 1;       \
$b = 2;       \
[ 1, 2, 3];   \

regexp: \d OK
hello world
HERE

dies-ok({ $otx.validate(q:to/HERE/) }, 'code block perl die');
HELLO WORLD
code: <<FOO
!perl
  die 100;
FOO
HERE

done-testing;

