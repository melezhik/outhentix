use v6;
use Test;
use Outhentix;

plan 3;

ok 1, 'Module loaded';
my $otx = Outhentix.new;
lives-ok { $otx.parse('') }, "'' parsed";
lives-ok { $otx.parse('OK') }, "OK parsed";
