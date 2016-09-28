use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => [1...99].join("") , check-max-len => 9 );

$otx.validate([1...99].join(""));

$otx.results.say;

