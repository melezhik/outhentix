use v6;

use Outhentix::DSL;

my $otx = Outhentix::DSL.new( text => q:to/HERE/, debug-mode => 0 );
  foo value
  bar value
HERE

$otx.validate(q:to/CHECK/);

    generator: <<CODE
    my %d = 'foo' => 'foo value', 'bar' => 'bar value';
    %d.keys.map({  my $k = $_; ["#$k",  %d{$k}]    })

CODE
CHECK

say $otx.results;


#my %d = 'foo' => 'foo value', 'bar' => 'bar value';
# %d.keys.map:  { "# $_", %d{$_}  }
#say %d.keys;

