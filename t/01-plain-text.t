use v6;
use Test;
use Outhentix::DSL;
plan 2;
ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new(debug-mode => 2);
lives-ok { $otx.validate('OK') }, "OK validated";
