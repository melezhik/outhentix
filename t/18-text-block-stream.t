use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/);

1
2
3
4
5
6
7
8
9

OUT

$otx.validate(q:to/HERE/);
begin:
regexp: \d+
regexp: \d+
end:
HERE

is-deeply $otx.stream, [["1", "2"], ["2", "3"], ["3", "4"], ["4", "5"], ["5", "6"], ["6", "7"], ["7", "8"], ["8", "9"]], 'valid stream (dubs)';

$otx.validate(q:to/HERE/);
begin:
regexp: \d+
regexp: \d+
regexp: \d+
end:
HERE

is-deeply $otx.stream, [["1", "2", "3"], ["2", "3", "4"], ["3", "4", "5"], ["4", "5", "6"], ["5", "6", "7"], ["6", "7", "8"], ["7", "8", "9"]], 'valid stream (triples)';

done-testing;
