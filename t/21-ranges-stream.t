use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/
start 100 end

start
    0
    3
    4
    5
end

start
    6
    7
    8
    9
    10
    11
    12
end

    1
    2
    73
OUT

);

$otx.validate(q:to/HERE/);
  between: start end
  regexp: (\d+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'output match' .* '\d+'/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';

is-deeply $otx.stream, [
  ["    0", "    3", "    4", "    5"],
  ["    6", "    7", "    8", "    9", "    10", "    11", "    12"],
], 'correct stream';

is-deeply $otx.captures, [
  ["0"], ["3"], ["4"], ["5"], 
  ["6"], ["7"], ["8"], ["9"], ["10"], 
  ["11"], ["12"]], 
'correct captures';

$otx.validate(q:to/HERE/);
  reset_context:
  regexp: (\d+)
HERE

is-deeply $otx.captures, [
  ["100"], ["0"], ["3"], 
  ["4"], ["5"], ["6"], ["7"], ["8"], ["9"], ["10"], 
  ["11"], ["12"], ["1"], ["2"], ["73"]
], 'correct captures, without range applied';

done-testing;
