use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/HERE/,
  one for 1
  two for 2
  three for 3
HERE

);

$otx.validate(q:to/HERE/);
HELLO WORLD
generator: <<FOO
  [
    'regexp: (\w+) \s+ (\d+)',
    'three for 3'
  ];
FOO
HERE

cmp-ok $otx.results.elems, '==', 3, 'correct array length';

ok ! $otx.results[0]<status>, 'correct status (HELLO WORLD)';
ok $otx.results[1]<status>, 'correct status (regexp check)';
ok $otx.results[2]<status>, 'correct status (three for 3 check)';

cmp-ok $otx.results[0]<message>, '~~', /'output match' .* 'HELLO WORLD'/, 'correct message (regexp check)';
cmp-ok $otx.results[1]<message>, '~~', /'output match' .* '(\w+) \s+ (\d+)'/, 'correct message (regexp check)';
cmp-ok $otx.results[2]<message>, '~~', /'output match' .* 'three for 3'/, 'correct message (three for 3 check)';

done-testing;
