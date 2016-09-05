use v6;
use Test;
use Outhentix::DSL;

plan 3;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0);
lives-ok( { $otx.validate(q:to/HERE/) }, 'generator block here string');
HELLO WORLD
generator: <<FOO
  my $a=1;
  my $b=2;
  [$a,$b];
FOO
regexp: \d OK
hello world
HERE

lives-ok( { $otx.validate(q:to/HERE/) }, 'generator block back slash');
HELLO WORLD
generator:      \
my $a = 1;      \
my $b = 2;      \
[ 1, 2, 3]      \

regexp: \d OK
hello world
HERE

$otx.validate(q:to/HERE/);
HELLO WORLD
generator:      \
my $a = 1;      \
my $b = 2;      \
[ 1, 2, 3]      \

regexp: \d OK
hello world
HERE

