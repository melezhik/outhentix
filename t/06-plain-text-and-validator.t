use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => 'HELLO WORLD!!!'
);

$otx.validate(q:to/HERE/);
HELLO WORLD
validator: <<FOO
  [ True, 'this is true' ]
FOO
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 2, 'correct array length';

ok $otx.results[0]<status>, 'correct status (plain check)';
ok $otx.results[1]<status>, 'correct status (validator check)';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* 'HELLO WORLD'/, 'correct message (plain check)';
cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type (plain check)';

cmp-ok $otx.results[1]<message>, 'eq', 'this is true', 'correct message (validator check)';
cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type (validator check)';
 
done-testing;
