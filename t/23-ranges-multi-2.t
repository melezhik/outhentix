use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/
    foo
        Z
        0
        1
        A
    bar

    foo
        2
        4
        6
        8
    bar

    foo
        1
        3
        B
    bar
OUT

);

$otx.validate(q:to/HERE/);
between: foo bar
  regexp: A
  regexp: \d
  regexp: \d
  regexp: \d
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 4, 'correct array length';

for 0 ... 3 -> $i {
  ok $otx.results[$i]<status>, 'correct status' ~ ' check N ' ~ $i+1;
}

is-deeply $otx.stream, [
  ["        A", "        0", "        1"],
], 'correct stream';

done-testing;
