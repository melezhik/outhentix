use v6;
use Test;
use Outhentix::DSL;

plan 2;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);

$otx.validate(q:to/HERE/);
HELLO WORLD
code: <<FOO
!perl
  $a=1;
  $b=2;
  [$a,$b]
regexp: \d OK
hello world
HERE

CATCH { 
  when Outhentix::DSL::Error::UnterminatedBlock { 
    ok True, 'unterminated block error catched'; 
  };

  default {
    ok False, 'unterminated block error catched';
  };
} 
