use v6;
use Test;
use Outhentix;
plan 2;
ok 1, 'Module loaded';

my $otx = Outhentix.new(debug-mode => 2);
lives-ok { $otx.validate('OK') }, "OK validated";

