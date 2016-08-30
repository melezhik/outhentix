my $s1 = '
REGEXP
CODE: FOO 

  OK 

  OK 

FOO
';

my $s = '
REGEXP:
CODE: FOO
OK
FOO
';


grammar Foo {

  token TOP { ^ ( <CODE> | <REGEXP> )+ $ }

  rule CODE {
     \s* 'CODE: ' (\w+) .*? ^^$0$$ \s*
  }

  rule REGEXP {
     \s* 'REGEXP:' \s*
  }

  proto token value {*};

  token value:sym<CODE> { <CODE> }

  token value:sym<REGEXP> { <REGEXP> }


}

say Foo.parse($s);

