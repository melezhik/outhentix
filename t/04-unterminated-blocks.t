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
  hello
regexp: \d OK
last line
HERE

$otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);

$otx.validate(q:to/HERE/);
HELLO WORLD
code: <<FOO
!perl
  $a=1;
  hello
  $b=2;
  last line
HERE

CATCH { 

  when Outhentix::DSL::Error::UnterminatedBlock { 
    my $ex = $_;
    ok True, 'unterminated block error catched'; 
    like $ex.message, /'Unterminated multiline block found. Last line:' \s+ 'last line'/, 'correct error message';
    $ex.resume
  };

  default {
    ok False, 'unterminated block error catched';
    .resume;
  };

}

LEAVE {
  done-testing;
}

