use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/);

hello
world
jan
julia
alex

hello
world
Alex

a1a2a3a4
b1b2b3b4
A1a2a3a4
B1b2b3b4

OUT

$otx.validate(q:to/HERE/);
alex
hello
world
julia
alex
HERE

is-deeply $otx.stream, [], 'valid stream';

$otx.validate(q:to/HERE/);

begin:
hello
world
jan
julia
alex
end:

HERE

is-deeply $otx.stream, [['hello' ,'world' ,'jan' ,'julia' ,'alex'],], 'valid stream2';

$otx.validate(q:to/HERE/);

begin:
regexp: (a(\d+))
regexp: (b(\d+))
end:

HERE

is-deeply $otx.stream, [["a1a2a3a4", "b1b2b3b4"], ["A1a2a3a4", "B1b2b3b4"]], 'valid stream3';

done-testing;
