use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => 'HELLO', debug-mode => 0 );

$otx.validate(q:to/CHECK/);
  generator: [ 'H', 'E', 'L', 'O' ];
CHECK

say $otx.results;


