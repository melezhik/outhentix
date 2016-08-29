use v6;
use Test;
use Outhentix;

plan 5;

ok 1, 'Module loaded';
ok my $otx = Outhentix.new, 'instance of Outhentix created';
isa-ok $otx, 'Outhentix';
isa-ok $otx.has-context, 'Bool';
ok ! $otx.has-context, 'has-context is false be default';
diag $otx.perl;
