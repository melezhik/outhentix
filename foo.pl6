grammar Thing {
    token TOP { <check>+ }
    proto regex check {*}
    token check:sym<regexp> { <sym> ':' \s* (\N*)\n }
    token check:sym<code> { \s* <sym> ':' \s+ (\w+) .*? ^^$0$$ \s* }
}

class Actions {
    method check:sym<regexp>($/) { say "Got regexp $0" }
    method check:sym<code>($/) { say "Got code $/" }
}

Thing.parsefile('test.dat', :actions(Actions.new));

