use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => 'HELLO WORLD!!!'
);

$otx.validate(q:to/HERE/);
HELLO 
WORLD
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 2, 'correct array length';

ok $otx.results[0]<status>, 'correct status (plain check hello)';
ok $otx.results[1]<status>, 'correct status (plain check world)';

cmp-ok $otx.results[0]<message>, '~~', /'output match' .* 'HELLO'/, 'correct message (plain check hello)';
cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type (plain check hello)';

cmp-ok $otx.results[1]<message>, '~~', /'output match' .* 'WORLD'/, 'correct message (plain check world)';
cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type (plain check world)';

done-testing;
