use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/

  *

  a
  b
  c

  *

  d
  e
  f

OUT

);

$otx.validate(q:to/HERE/);
  begin:
    regexp: \w+
    regexp: \w+
    regexp: \w+
  end:
HERE

$otx.stream.say;


$otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/

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

);

$otx.validate(q:to/HERE/);
  begin:
    regexp: \w+
    regexp: \w+
  end:
HERE

$otx.stream.say;

done-testing;
