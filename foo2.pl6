my $s = '
REGEXP:    hello
';


grammar Foo {
  token TOP { <regexp> }
  token regexp { \s* 'REGEXP:' \s+ (\w+) \s* }
}

class Actions {
  method TOP($/) {  say "TOP <" ~ $/ ~ '>'}
}


Foo.parse($s,actions => Actions).made;

