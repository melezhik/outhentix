use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => 'HELLO WORLD!!!'
);

$otx.validate(q:to/HERE/);
regexp: HELLO \s*
regexp: WORLD
regexp: (\w+)
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 3, 'correct array length';

ok $otx.results[0]<status>, 'correct status (regexp check hello)';
ok $otx.results[1]<status>, 'correct status (regexp check world)';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* 'HELLO'/, 'correct message (regexp check hello)';
cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type (plain check hello)';

cmp-ok $otx.results[1]<message>, '~~', /'text match' .* 'WORLD'/, 'correct message (regexp check world)';
cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type (regexp check world)';

done-testing;
