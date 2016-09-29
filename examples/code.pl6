use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => 'hello' );

$otx.validate(q:to/CHECK/);
  hello
  code: say "hi there"
CHECK

say $otx.results;


