use Terminal::ANSIColor;

grammar Outhentix::DSL::Grammar {

  token TOP { <otx>+ }

  proto regex otx {*}

  # regular expressions
  token otx:sym<regexp> { <sym> ':' \s* (\N*) \n  }

  # code blocks
  regex otx:sym<code> { <sym> ':' \s+ '<<' (FOO) .*  }

  token otx:sym<plain-text> { \s* \N+ \s* }

}

class Outhentix::DSL::Actions {
  method otx:sym<code> ($/) { say "code is here: <$/>"}
  method otx:sym<plain-text> ($/) { say "plain-text is here: <$/>"}
}

