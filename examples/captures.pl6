use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => q:to/HERE/ );
    1 - for one
    2 - for two
    3 - for three
HERE

$otx.validate(q:to/CHECK/);

regexp: (\d+) \s+ \- \s+ for \s+ (\w+)

CHECK

$otx.captures.perl.say;


