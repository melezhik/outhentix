use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/

  A
    1
    2
    3
  A

  A
    1
    2
    3
  A

OUT

);

$otx.validate(q:to/HERE/);
  between: A A
  regexp: \d
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 1, 'correct array length';

ok $otx.results[0]<status>, 'correct status';

cmp-ok $otx.results[0]<message>, '~~', /'text match' .* '\d'/, 'correct message';

cmp-ok $otx.results[0]<type>, 'eq', 'check-expression', 'correct type';

is-deeply $otx.stream, [["    1", "    2", "    3"], ["    1", "    2", "    3"]], 'correct stream';


done-testing;
