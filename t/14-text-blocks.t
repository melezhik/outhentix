use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/
  once
  upon a time
  there was a Outhentix
  Boy
OUT

);

$otx.validate(q:to/HERE/);
  begin:
    once
    upon a time
    there was a Outhentix
    regexp: Bo*
  end:
HERE

isa-ok $otx.results, 'Array';

cmp-ok $otx.results.elems, '==', 4, 'correct array length';

ok $otx.results[0]<status>, 'correct status (once)';
ok $otx.results[1]<status>, 'correct status (upon a time)';
ok $otx.results[2]<status>, 'correct status (there was a ...)';
ok $otx.results[3]<status>, 'correct status (regexp: Bo*)';

cmp-ok $otx.results[0]<message>, '~~', /'[b] text match' .* 'once'/, 'correct message (once)';
cmp-ok $otx.results[1]<message>, '~~', /'[b] text match' .* 'upon a time'/, 'correct message (upon a time)';
cmp-ok $otx.results[2]<message>, '~~', /'[b] text match' .* 'there was'/, 'correct message (there was)';
cmp-ok $otx.results[3]<message>, '~~', /'[b] text match' .* 'Bo*'/, 'correct message (regexp: Bo*)';

for 0 ... 3 -> $i {
  cmp-ok $otx.results[$i]<type>, 'eq', 'check-expression', 'correct type (check N ' ~ $i ~ ')';
}

done-testing;
