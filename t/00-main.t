use v6;
use Test;
use Outhentix::DSL;

plan 5;

ok 1, 'Module loaded';
ok my $otx = Outhentix::DSL.new, 'instance of Outhentix::DSL created';
isa-ok $otx, 'Outhentix::DSL';
isa-ok $otx.has-context, 'Bool';
ok ! $otx.has-context, 'has-context is false be default';

