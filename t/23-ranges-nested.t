use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/
foo

1
2
3

    fooo
    100
    baaar

bar

fooo

10
20
30

baaar
OUT

);

$otx.validate(q:to/HERE/);
between: foo bar
# here will be everything
# between foo and bar lines
regexp: (\d+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* '(\d+)'/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';


is-deeply $otx.captures, [
["1"], ["2"], ["3"], ["100"]
], 'correct captures';

is-deeply $otx.stream, [
  ["1", "2", "3", "    100"],
], 'correct stream';

$otx.validate(q:to/HERE/);
between: fooo baaar
# here will be everything
# between fooo and baaar lines
# NOT necessarily inside foo bar block
regexp: (\d+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 2, 'correct array length';

ok $otx.results[1]<status>, 'correct status (2nd range)';

cmp-ok $otx.results[1]<message>, '~~', /'text match' .* '(\d+)'/, 'correct message (2nd range)';

cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type (2nd range)';

is-deeply $otx.captures, [
["100"], ["10"], ["20"], ["30"]
], 'correct captures (2nd range)';

is-deeply $otx.stream, [
["    100"], ["10", "20", "30"]
], 'correct stream (2nd range)';

done-testing;

