my $s = '
REGEXP:    hello
10
';


grammar Foo {

  token TOP { <regexp> | <digit> }

  rule regexp {
     \s* 'REGEXP:' \s* (\w+) \s*
  }

  rule digit {
    \d
  }

}

class Actions {
  method regexp($/) {  say "regexp <" ~ $/ ~ '>'}
  method digit($/) {  say "digit <" ~ $/ ~ '>'}
}


Foo.parse($s,actions => Actions).made;

