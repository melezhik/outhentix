use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/
foo
    1
    2
    11
    22
bar
OUT

);

$otx.validate(q:to/HERE/);
  between: foo bar
  regexp: 1
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'output match' .* 1/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';

is-deeply $otx.stream, [
  ["    1", "    11"],
], 'correct stream';

$otx.validate(q:to/HERE/);
  regexp: 2
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 2, 'correct array length (2)';

ok $otx.results[1]<status>, 'correct status';

cmp-ok $otx.results[1]<message>, '~~', /'output match' .* 2/, 'correct message (2)';

cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type (2)';

is-deeply $otx.stream, [
  ["    1", "    11", "    2", "    22"],
] , 'correct stream';

done-testing;
