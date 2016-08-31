use v6;
use Test;
use Outhentix;

plan 2;

ok 1, 'Module loaded';
my $otx = Outhentix.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);
lives-ok( { $otx.validate(q:to/HERE/) }, 'code block');
HELLO WORLD
code: <<FOO
  $a=1;
  $b=2;
  [$a,$b]
FOO
regexp: /OK/
hello world
HERE

say $otx.results[0].WHAT;
