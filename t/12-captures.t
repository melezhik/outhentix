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

done-testing;
