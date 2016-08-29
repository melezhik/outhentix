use v6;
use Test;
use Outhentix;

plan 3;

ok 1, 'Module loaded';
ok my $otx = Outhentix.new, 'instance of Outhentix created';
isa-ok $otx, 'Outhentix';
