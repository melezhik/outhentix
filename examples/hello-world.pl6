use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => q:to/HERE/ );
    Hello
    My name is Outhentix!
HERE

$otx.validate(q:to/CHECK/);
    Hello
    regexp: My \s+ name \s+ is
CHECK

for $otx.results -> $r {
    say $r
}


