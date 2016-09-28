use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => 'HELLO WORLD!!!' ~ "\n" ~ 'goodbye!'
);

$otx.validate(q:to/HERE/);
within: HELLO \s+ \w
WORLD
goodbye!
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 3, 'correct array length';

ok $otx.results[0]<status>, 'correct status (within regexp check)';
ok $otx.results[1]<status>, 'correct status (plain text check - world)';
ok $otx.results[2]<status>, 'correct status (plain text check - goodbye!)';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* 'HELLO \s+ \w'/, 'correct message (within regexp check)';
cmp-ok $otx.results[1]<message>, '~~', /'HELLO WORLD!!!' .* 'match \'WORLD ...'/, 'correct message (plain text check - world)';
cmp-ok $otx.results[2]<message>, '~~', /'text match' .* 'goodbye!'/, 'correct message (plain text check - goodbye!)';

for 0 ... 2 -> $i {
  cmp-ok $otx.results[$i]<type>, 'eq', 'check-expression', 'correct type (check N ' ~ $i ~ ')';
}
done-testing;
