use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/
    foo
        0
    bar

    foo
        2
        4
        6
        8
    bar

    foo
        1
        3
    bar
OUT

);

$otx.validate(q:to/HERE/);
between: foo bar
regexp: (\d+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* '(\d+)'/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';

is-deeply $otx.stream, [
  ["        0"], 
  ["        2", "        4", "        6", "        8"], 
  ["        1", "        3"]
], 'correct stream';

done-testing;

