use v6;


use Outhentix::Context;

grammar Otx::DSL {
  token TOP { .* };
}

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
    my $o = Otx::DSL.parse($check-list);
    unless $o {
      die "failed to parse check list";
    }
    return $o.made;
  }

}



