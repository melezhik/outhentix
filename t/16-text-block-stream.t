use v6;
use Test;
use Outhentix::DSL;

ok 1, 'Module loaded';

my $otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/);

    foo
        a
        b
        c
    bar

    foo
        1
        2
        3
    bar

    foo
        0
        00
        000
    bar

    foo
        .
        ..
        ...
        ....
    bar

OUT

$otx.validate(q:to/HERE/);
begin:
    foo
      regexp: \S+
      regexp: \S+
      regexp: \S+
    bar
end:
HERE

is-deeply $otx.stream, [

    ["    foo", "        a", "        b", "        c",    "    bar"    ], 
    ["    foo", "        1", "        2", "        3",    "    bar"    ], 
    ["    foo", "        0", "        00", "        000", "    bar" ]
], 'valid stream';

$otx = Outhentix::DSL.new( 
  debug-mode => %*ENV<OTX_DEBUG> ?? %*ENV<OTX_DEBUG>.Int !! 0,
  output => q:to/OUT/);

foo
1
2
3
bar

foo
a
b
c
bar

foo
A
B
C
bar

foo
bar


foo
1
2
bar

OUT

$otx.validate(q:to/HERE/);

begin:
  foo
    regexp: \S+
    regexp: \S+
    regexp: \S+
  bar
end:

HERE

is-deeply $otx.stream, [["foo", "1", "2", "3", "bar"], ["foo", "a", "b", "c", "bar"], ["foo", "A", "B", "C", "bar"]], 'valid stream2';


done-testing;
