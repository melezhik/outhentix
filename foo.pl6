my $s = '
REGEXP:    hello
';


grammar Foo {

  token TOP { ^ ( <CODE> | <REGEXP> )+ $ }

  rule CODE {
     \s* 'CODE: ' (\w+) .*? ^^$0$$ \s*
  }

  rule REGEXP {
     \s* 'REGEXP:' \s ** ^1..5 (\w+) \s*
  }

  proto token value {*};

  token value:sym<CODE> { <CODE> }

  token value:sym<REGEXP> { <REGEXP> }


}

class Actions {

  #method TOP($/) {  say "OK"}
  method CODE($/) { say "CODE " ~ $/ }
  method REGEXP($/) { say "REGEXP> " ~ $/ ~ '<' }

}


Foo.parse($s,actions => Actions).made;

