use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/);

*

a
b
c

*

d
e
f

*

g
h
i

OUT

$otx.validate(q:to/HERE/);
  begin:
    regexp: \w+
    regexp: \w+
    regexp: \w+
  end:
HERE

is-deeply $otx.stream, [ [  'a', 'b', 'c' ], [  'd', 'e', 'f'], [  'g', 'h', 'i'] ], 'three triads search';

say "--------------------------------------------";

$otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/);

***

a
b
c

*

d
e

***

f
g
h

OUT

$otx.validate(q:to/HERE/);
  begin:
    regexp: \w+
    regexp: \w+
    regexp: \w+
  end:
HERE


is-deeply $otx.stream, [ [  'a', 'b', 'c' ], [ 'f', 'g', 'h' ] ], 'fisrt and last triads search';


say "--------------------------------------------";

$otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  text => q:to/OUT/);

a
b

c
d
e
  
f
g

h

i
j

OUT

$otx.validate(q:to/HERE/);
  begin:
    regexp: \w+
    regexp: \w+
  end:
HERE

is-deeply $otx.stream, [ [ 'a', 'b'], [ 'c', 'd' ], [ 'd', 'e' ],  [ 'f', 'g'],  [ 'i', 'j'] ], 'five dubs search';

done-testing;
