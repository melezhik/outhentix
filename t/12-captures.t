use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => 'HELLO WORLD!!!' ~ "\n" ~ 'HELLO WORLD!!!'
);

$otx.validate(q:to/HERE/);
regexp: (\w+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length (results)';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.captures.elems, '==', 2, 'correct array length (captures)';

isa-ok $otx.captures[0], Array, 'first capture is ARRAY';

isa-ok $otx.captures[1], Array, 'second capture is ARRAY';

cmp-ok $otx.captures[0].elems, '==', 2, 'first capture has 2 (sub)captures';

cmp-ok $otx.captures[1].elems, '==', 2, 'second capture has 2 (sub)captures';

cmp-ok $otx.captures[0][0], 'eq', 'HELLO', 'capture(1,1) has right value (HELLO)';

cmp-ok $otx.captures[0][1], 'eq', 'WORLD', 'capture(1,2) has right value (WORLD)';

cmp-ok $otx.captures[1][0], 'eq', 'HELLO', 'capture(2,1) has right value (HELLO)';

cmp-ok $otx.captures[1][1], 'eq', 'WORLD', 'capture(2,2) has right value (WORLD)';


done-testing;
