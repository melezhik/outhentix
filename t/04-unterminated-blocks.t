use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);

lives-ok({ $otx.validate(q:to/HERE/) },'code block (here string)');
HELLO WORLD
code: <<FOO
!perl
  $a=1;
  $b=2;
  'hello';
HERE

$otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);

lives-ok({ $otx.validate(q:to/HERE/) },'code block back slash way');
HELLO WORLD
code: \
!perl  \
  $a=1; \ 
  $b=2; \ 
  'hello' \
HERE


done-testing;
