use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);

$otx.validate(q:to/HERE/);
assert: 1 this is true
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';
ok $otx.results[0]<status>, 'correct status';
cmp-ok $otx.results[0]<message>, 'eq', 'this is true', 'correct message';
cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';


$otx.validate(q:to/HERE/);
generator: <<FOO
[ 'assert: 1 this is a real true' ]
FOO
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 2, 'correct array length';
ok $otx.results[1]<status>, 'correct status';
cmp-ok $otx.results[1]<message>, 'eq', 'this is a real true', 'correct message';
cmp-ok $otx.results[1]<type>, 'eq', 'check-expression', 'correct type';
 
#$otx.results.perl.say;

done-testing;
