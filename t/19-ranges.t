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
  3
  foo
OUT

);

$otx.validate(q:to/HERE/);
  between: foo foo
  regexp: \d
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'output match' .* '\d'/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';


#say $otx.results;


done-testing;
