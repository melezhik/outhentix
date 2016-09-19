use v6;
use Test;
use Outhentix::DSL;
plan 2;
ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new(
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0
);

lives-ok { $otx.validate('OK') }, "OK validated";
