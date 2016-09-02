use v6;
use Test;
use Outhentix::DSL;

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
    my $ex = $_;
    ok True, 'unterminated block error catched'; 
    like $ex.message, /.*'last line:'\s+'[$a,$b]'/, 'correct error message';
  };

  default {
    ok False, 'unterminated block error catched';
  };

}

LEAVE {
  done-testing;
}

