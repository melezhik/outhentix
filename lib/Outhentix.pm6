use v6;


use Outhentix::Context;
use Outhentix::DSL;

class Outhentix {

  has Array @.results;
  has Array @.original-context;
  has Array @.current-context;
  has Outhentix::Context $.context-modificator;
  has Bool $.has-context = False;
  has Array @.succeed;
  has Array @.captures;
  has Str $.last-match-line;
  has Bool $.last-check-status;
  has Bool $.debug-mode = False;
  has Str $.output;
  has Int $.match-l = 40;
  has Hash $.languages;
  has Hash $.stream;

  method parse ($check-list) {
    my $o = Outhentix::DSL.parse($check-list);
    unless $o {
      die "failed to parse check list";
    }
    return $o.made;
  }

}



