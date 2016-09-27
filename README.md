# NAME

Outhentix::DSL

[![Build Status](https://travis-ci.org/melezhik/outhentix-dsl.svg)](https://travis-ci.org/melezhik/outhentix-dsl)


# NOTE

Outhentix::DSL is a Perl6 replacement of [Outthentic::DSL](https://github.com/melezhik/outthentic-dsl)

# SYNOPSIS

Outhentix::DSL - language to verify (un)structured text.

# Install

    $ panda Outhentix::DSL

# Developing

    $ git clone https://travis-ci.org/melezhik/outhentix-dsl 
    $ cd outhentix-dsl
    $ OTX_DEBUG=2 prove -e 'perl6 -I lib' -v -r t/
    $ panda --force install .

# Environment variables

I'll document these variables later. Here is just a list:

* OTX_DEBUG (1,2,3,4)
* OTX_STREAM_DEBUG (set|not set)

# Glossary

## Input text

An arbitrary, often unstructured text being verified. It could be any text.

Examples:

* html code
* xml code
* json 
* plain text
* emails :-)
* http headers
* another program languages code

## Outhentix DSL

* Is a language to verify _arbitrary_ text

* Outhentix DSL is both imperative and declarative language

### Declarative way

You define rules ( check expressions ) to describe expected content.

### Imperative way

You _extend_ a process of verification using regular programming languages - like Perl6, Perl5, Bash and Ruby, see
examples below.


## DSL code

A  program code written on outhentix DSL language to verify text input.

## Search context

Verification process is carried out in a given _context_.

But default search context is the same as original input text stream. 

Search context could be however changed in some conditions.

## DSL parser

DSL parser is the program which:

* parses DSL code

* parses text input

* verifies text input ( line by line ) against check expressions ( line by line )


## Verification process

Verification process consists of matching lines of text input against check expressions.

This is schematic description of the process:


    For every check expression in check expressions list.
        Mark this check step as in unknown state.
        For every line in input text.
            Does line match check expression? Check step is marked as succeeded.
            Next line.
        End of loop.
        Is this check step marked in unknown state? Mark this check step as in failed state.  
        Next check expression.
    End of loop.
    Are all check steps succeeded? Input text is verified.
    Vise versa - input text is not verified.
    
A final _presentation_ of verification results should be implemented in a certain [client](#clients) _using_ [parser api](#parser-api) and not being defined at this scope. 

For the sake of readability a _fake_ results presentation layout is used in this document. 

## Parser API

Outhentix::DSL provides program api for client applications:

    use v6;
    use Test;

    use Outhentix::DSL;

    my $otx = Outhentix::DSL.new( output => q:to/HERE/);
        Hello
        My name is Outhentix!
    HERE

    $outh->validate(q:to/CHECK/);
        Hello
        regexp: My \s+ name \s+ is 
    CHECK

    for otx.results -> $r {
        ok $r{status}, $r{message} if $r{type} eq 'check_expression';
    }

Methods list:

### new

This is constructor, create Outhentix::DSL instance. 

Obligatory parameters are:

* input text string 

Optional parameters are passed as hash:

* match_l - truncate matching strings to {match_l} bytes

Default value is \`40'

* debug_mod - enable debug mode

    * Possible values is 0,1,2,3.

    * Set to 1 or 2 or 3 if you want to see some debug information in validation results.

    * Increasing debug_mod value means more low level information appeared.

    * Default value is \`0' - means do not create debug messages.

### validate

Perform verification process. 

Obligatory parameter is:

* a string with DSL code

### results  

Returns validation results as array containing { type, status, message } hashes.

## Outhentix clients

Client is a external program using DSL API. Existed outhentix clients:

* [Swat](https://github.com/melezhik/swat) - web application testing tool

* [Outhentix](https://github.com/melezhik/outhentix) -  multipurpose scenarios framework

More clients wanted :) , please [write me](mailto:melezhik@gmail.com) if you have one!

# DSL code syntax

Outhentix DSL code comprises following entities:

## Check expressions:

    * plain     strings
    * regular   expressions
    * text      blocks
    * within    expressions
    * asserts   expressions
    * range     expressions

## Comments

## Blank lines

## Code expressions

## Generator expressions

## Validator expressions

# Check expressions

Check expressions define patterns to match input text stream. 

Here is a simple example:

Input text:

    HELLO
    HELLO WORLD
    My birth day is: 1977-04-16


DSL code:

    HELLO
    regexp: \d\d\d\d-\d\d-\d\d


Results - verified:

    +--------+------------------------------+
    | status | message                      |
    +--------+------------------------------+
    | OK     | matches "HELLO"              |
    | OK     | matches /\d\d\d\d-\d\d-\d\d/ |
    +--------+------------------------------+


There are two basic types of check expressions:

* [plain text expressions](#plain-text-expressions) 

* [regular expressions](#regular-expressions).

# Plain text expressions 

Plain text expressions are just a lines should be _included_ at input text stream.

DSL code:
        
        I am ok
        HELLO Outhentix

Input text:

    I am ok , really
    HELLO Outhentix !!!

Results: verified
 
Plain text expressions are case sensitive:

Input text:

    I am OK
 
Results: not verified

    
# Regular expressions

Similarly to plain text matching, you may require that input lines match some regular expressions:

DSL code:

    regexp: \d\d\d\d-\d\d-\d\d # date in format of YYYY-MM-DD
    regexp: Name: \w+ # name
    regexp: App Version Number: \d+\.\d+\.\d+ # version number

Input text:

    2001-01-02
    Name: outhentix
    App Version Number: 1.1.10
 
Result - verified

 
# One or many?

Parser does not care about _how many times_ a given check expression is matched in input text.

If at least one line in a text match the check expression - _this check_ is considered as succeeded.

Parser  _accumulate_ all matching lines for given check expression, so they could be processed.

Input text:

    1 - for one
    2 - for two
    3 - for three       

    regexp: (\d+) for (\w+)
    code: for my $c( @{captures()}) {  print $c->[0], "/", $c->[1], "\n"}

Output:

    1/one
    2/two
    3/three


See ["captures"](#captures) section for full explanation of a captures mechanism:

# Comments, blank lines and text blocks

Comments and blank lines don't impact verification process but one could use them to improve code readability.

# Comments

Comment lines start with \`#' symbol, comments chunks are ignored by parser.


DSL code:

    # comments could be represented at a distinct line, like here
    The beginning of story
    Hello World # or could be added for the existed expression to the right, like here

# Blank lines

Blank lines are ignored as well.

DSL code:

    # every story has the beginning
    The beginning of a story
    # then 2 blank lines


    # end has the end
    The end of a story

But you **can't ignore** blank lines in a \`text block' context ( see \`text blocks' subsection ).

Use \`:blank_line' marker to match blank lines.

DSL code:

    # :blank_line marker matches blank lines
    # this is especially useful
    # when match in text blocks context:

    begin:
        this line followed by 2 blank lines
        :blank_line
        :blank_line
    end:

# Text blocks

Sometimes it is very helpful to match against a \`sequence of lines' like here.

DSL code:

    # this text block
    # consists of 5 strings
    # going consecutive

    begin:
        # plain strings
        this string followed by
        that string followed by
        another one
        # regexps patterns:
        regexp: with (this|that)
        # and the last one in a block
        at the very end
    end:

Input text:

    this string followed by
    that string followed by
    another one string
    with that string
    at the very end.

Result - verified

Input text:

    that string followed by
    this string followed by
    another one string
    with that string
    at the very end.

Result - not verified

\`begin:' \`end:' markers decorate \`text blocks' content. 

Markers should not be followed by any text at the same line.

## Don't forget to close the block ...

Be aware if you leave "dangling" \`begin:' marker without closing \`end': somewhere else 
parser will remain in a \`text block' mode till the end of the file, which is probably not you want:

DSL code:

    begin:
        here we begin
        and till the very end of test
    
        we are in `text block` mode
    
# Code expressions

Code expressions are just a pieces of 'some language code' you may inline and execute **during parsing** process.

By default, if *language* is no set Perl language is assumed. Here is example:

DSL code:

    # Perl expression 
    # between two check expressions
    Once upon a time
    code: print "hello I am Outhentix"
    Lived a boy called Outhentix


Output:

    hello I am Outhentix

Internally once DSL code gets parsed it is "turned" into regular Perl code:

    execute_check_expression("Once upon a time");
    eval 'print "Lived a boy called Outhentix"';
    execute_check_expression("Lived a boy called Outhentix");

When use Perl expressions be aware of:

* Perl expressions are executed by Perl eval function in context of `package main`, please be aware of that.

* Follow [http://perldoc.perl.org/functions/eval.html](http://perldoc.perl.org/functions/eval.html) to know more about Perl eval function.

One may use other languages in code expressions. Use should use \`here' document style ( see [multiline expressions](#Multiline expressions) section ) to insert your code and
set shebang to define a language. Here are some examples:


## bash 

    code:  <<HERE
    !bash

    echo '# hello I am Outhentix'
    HERE


## ruby

    code: <<CODE
    !ruby

    puts '# hello I am Outhentix'
    CODE

# Asserts

Asserts are simple statements with one of two values : true|false, a second assert parameter is just a description.

DSL code

    assert: 0 'this is not true'
    assert: 1 'this is true'

Asserts almost always are created dynamically with generators. See next section.
 
    
# Generators

* Generators is the way to _generate new outhentix entries on the fly_.

* Generator expressions like code expressions are just a piece of code to be executed.

* The only requirement for generator code - it should return _new outhentix entities_.

* If you use Perl in generator expressions ( which is by default ) - last statement in your
code should return reference to array of strings. Strings in array would _represent_ a _new_ outhentix entities.

* If you use not Perl language in generator expressions to produce new outhentix entities you should print them
into **stdout**. See examples below.

* A new outhentix entries are passed back to parser and executed immediately.

Generators expressions start with \`:generator' marker.

Here is simple example.

DSL code:

    # original check list

    Say
    HELLO
 
    # this generator creates 3 new check expressions:

    generator: <<CODE
    [ 
      'say', 
      'hello', 
      'again'
    ]
    CODE


Updated check list:

    Say
    HELLO
    say
    hello
    again



If you use not Perl in generator expressions, you have to print entries into stdout instead of returning
an array reference like in Perl. Here are some generators examples for other languages:


    generator: <<CODE
    !bash
      echo say
      echo hello
      echo again
    CODE

    generator: <<CODE
    !ruby
      puts 'say'
      puts 'hello'
      puts 'again'
    CODE

Here is more complicated example using Perl.

DSL code:


    # this generator generates
    # comment lines
    # and plain string check expressions:

    generator: <<CODE    
    my %d = { 
      'foo' => 'foo value', 
      'bar' => 'bar value' 
    };     
    [ 
      map  { 
        ( "# $_", "$data{$_}" )  
      } keys %d 
    ]
    CODE


Updated check list:

    # foo
    foo value
    # bar
    bar value


Generators could produce not only check expressions but code expressions and ... another generators.

This is fictional example.

Input Text:

    A
    AA
    AAA
    AAAA
    AAAAA

DSL code:

    generator:  <<CODE
    sub next_number {                       
        my $i = shift;                       
        $i++;                               
        return [] if $i>=5;                 
        [                                   
            'regexp: ^'.('A' x $i).'$'      
            "generator: next_number($i)"     
        ]  
    }
    CODE

Generators are commonly used to create an asserts.

Input:

    number: 10

DSL code:


    number: (\d+)

    generator: <<CODE
    !ruby
      puts "assert: #{capture()[0] == 10}, you've got 10!"  
    CODE


# Validators

WARNING!!! You should prefer asserts over validators. Validators feature will be deprecated soon!

Validator expressions are perl code expressions used for dynamic verification.

Validator expressions start with \`validator:' marker.

A Perl code inside validator block should _return_ array reference. 

* Once code is executed a returned array structure treated as:

  * first element - is a status number ( Perl true or false )

  * second element - is a helpful message 

Validators a kind of check expressions with check logic _expressed_ in program code. Here is examples:

DSL code:

    # this is always true
    validator: [ 10>1 , 'ten is bigger then one' ]

    # and this is not
    validator: [ 1>10, 'one is bigger then ten'  ]

    # this one depends on previous check
    regexp: credit card number: (\d+)
    validator: [ captures()->[0]-[0] == '0101010101', 'I know your secrets!'  ]


    # and this could be any
    validator: [ int(rand(2)) > 1, 'I am lucky!'  ]
    

Validators are often used with the [\`captures expressions'](#captures). This is another example.

Input text:


    # my family ages list
    alex    38
    julia   32
    jan     2


DSL code:


    # let's capture name and age chunks
    regexp: /(\w+)\s+(\d+)/

    validator: <<CODE
    my $total=0;                        
    for my $c (@{captures()}) {         
        $total+=$c->[0];                
    }                                   
    [ ( $total == 72 ), "total age" ] 

    CODE


# Multiline expressions

## Multilines in check expressions

When parser parses check expressions it does it in a _single line mode_ :

* a check expression is always single line string

* input text is parsed in line by line mode, thus every line is validated against a single line check expression

Example.

    # Input text

    Multiline
    string
    here

DSL code:


    # check list
    # consists of
    # single line entries

    Multiline
    string
    here
    regexp: Multiline \n string \n here



Results - not verified:

    +--------+---------------------------------------+
    | status | message                               |
    +--------+---------------------------------------+
    | OK     | matches "Multiline"                   |
    | OK     | matches "string"                      |
    | OK     | matches "here"                        |
    | FAIL   | matches /Multiline \n string \n here/ |
    +--------+---------------------------------------+


Use text blocks if you want to _represent_ multiline checks.

## Multilines in code expressions, generators and validators

Perl expressions, validators and generators could contain multilines expressions

There are two ways to write multiline expressions:

* using `\` delimiters to split multiline string to many chunks

* using HERE documents expressions 


### Back slash delimiters

\`\' delimiters breaks a single line text on a multi lines.

Example:

    # What about to validate stdout
    # With sqlite database entries?

    generator:                                                          \

    use DBI;                                                            \
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/data/test.db","","");   \
    my $sth = $dbh->prepare("SELECT name from users");                  \
    $sth->execute();                                                    \
    my $results = $sth->fetchall_arrayref;                              \

    [ map { $_->[0] } @${results} ]


### HERE documents expressions 

Is alternative to make your multiline code more readable:


    # What about to validate stdout
    # With sqlite database entries?

    generator: <<CODE

    use DBI;                                                            
    my $dbh = DBI->connect("dbi:SQLite:dbname=t/data/test.db","","");   
    my $sth = $dbh->prepare("SELECT name from users");                  
    $sth->execute();                                                    
    my $results = $sth->fetchall_arrayref;                              

    [ map { $_->[0] } @${results} ]

    CODE

# Captures

Captures are pieces of data get captured when parser validate lines against a regular expressions:

Input text:

    # my family ages list.
    alex    38
    julia   32
    jan     2


    # let's capture name and age chunks
    regexp: /(\w+)\s+(\d+)/
    code: << CODE                                 
        for my $c (@{captures}){            
            print "name:", $c->[0], "\n";   
            print "age:", $c->[1], "\n";    
        }
    CODE

Data accessible via captures():

    [
        ['alex',    38 ]
        ['julia',   32 ]
        ['jan',     2  ]
    ]


Then captured data usually good fit for assert checks.

DSL code


    generator: << CODE
    !ruby
    total=0                 
    captures().each do |c|
        total+=c[0]
    end           
    puts "assert: #{total == 72} 'total age of my family'"
    CODE

## captures() function

captures() function returns an array reference holding all the chunks captured during _latest regular expression check_.

Here is another example:

    # check if stdout contains lines
    # with date formatted as date: YYYY-MM-DD
    # and then check if first date found is yesterday

    regexp: date: (\d\d\d\d)-(\d\d)-(\d\d)

    generator:  <<CODE
    use DateTime;                       
    my $c = captures()->[0];            
    my $dt = DateTime->new( year => $c->[0], month => $c->[1], day => $c->[2]  ); 
    my $yesterday = DateTime->now->subtract( days =>  1 );                        
    my $true_or_false = (DateTime->compare($dt, $yesterday) == 0);
    [ 
        "assert: $true_or_false first day found is - $dt and this is a yesterday"
    ];

    CODE

## capture() function

capture() function returns a _first element_ of captures array. 

it is useful when you need data _related_ only  _first_ successfully matched line.

DSL code:

    # check if  text contains numbers
    # a first number should be greater then ten

    regexp: (\d+)
    generator: [ "assert: ".( capture()->[0] >  10 )." first number is greater than 10 " ]

# Search context modificators

Search context modificators are special check expressions which not only validate text but modify search context.

By default search context is equal to original input text stream. 

That means parser executes validation use all the lines when performing checks 

However there are two search context modificators to change this behavior:
 

* within expressions

* range expressions


## Within expressions

Within expression acts like regular expression - checks text against given patterns 

Text input:

    These are my colors

    color: red
    color: green
    color: blue
    color: brown
    color: back

    That is it!

DSL code:

    # I need one of 3 colors:

    within: color: (red|green|blue)

Then if checks given by within statement succeed _next_ checks will be executed _in a context of_ succeeded lines:
 
    # but I really need a green one
    green

The code above does follows:

* try to validate input text against regular expression "color: (red|green|blue)"

* if validation is successful new search context is set to all _matching_ lines

These are:

    color: red
    color: green
    color: blue


* thus next plain string checks expression will be executed against new search context

Results - verified:

    +--------+------------------------------------------------+
    | status | message                                        |
    +--------+------------------------------------------------+
    | OK     | matches /color: (red|green|blue)/              |
    | OK     | /color: (red|green|blue)/ matches green        |
    +--------+------------------------------------------------+



Here more examples:

    # try to find a date string in following format
    within: date: \d\d\d\d-\d\d-\d\d

    # we only need a dates in 2000 year
    2000-

Within expressions could be sequential, which effectively means using \`&&' logical operators for within expressions:


    # try to find a date string in following format
    within: date: \d\d\d\d-\d\d-\d\d

    # and try to find year of 2000 in a date string
    within: 2000-\d\d-\d\d

    # and try to find month 04 in a date string
    within: \d\d\d\d-04-\d\d

Speaking in human language chained within expressions acts like _specifications_. 

When you may start with some generic assumptions and then make your requirements more specific. A failure on any step of chain results in
immediate break. 


# Range expressions

Range expressions also act like _search context modificators_ - they change search area to one included
_between_ lines matching right and left regular expression of between statement.


It is very similar to what Perl [range operator](http://perldoc.perl.org/perlop.html#Range-Operators) does 
when extracting pieces of lines inside stream:

    while (<STDOUT>){
        if /foo/ ... /bar/
    }

Outhentix analogy for this is range expression:

    between: foo bar

Between statement takes 2 arguments - left and right regular expression to setup search area boundaries.

A search context will be all the lines included between line matching left expression and line matching right expression.

A matching (boundary) lines are not included in range. 

These are few examples:

Parsing html output

Input text:

    <table cols=10 rows=10>
        <tr>
            <td>one</td>
        </tr>
        <tr>
            <td>two</td>
        </tr>
        <tr>
            <td>the</td>
        </tr>
    </table>


DSL code:

    # between expression:
    between: <table.*> <\/table>
    regexp: <td>(\S+)<\/td>

    # or even so
    between: <tr.*> <\/tr>
    regexp: <td>(\S+)<\/td>


## Multiple range expressions

Multiple range expressions could not be nested, every new between statement discards old search context and setup new one:

Input text:

    foo

        1
        2
        3

        FOO
            100
        BAR

    bar

    FOO

        10
        20
        30

    BAR

DSL code:

    between: foo bar

    code: print "# foo/bar start"

    # here will be everything
    # between foo and bar lines

    regexp: \d+

    code: <<CODE                           
    for my $i (@{captures()}) {     
        print "# ", $i->[0], "\n"   
    }                               
    print "# foo/bar end"

    CODE

    between: FOO BAR

    code: print "# FOO/BAR start"

    # here will be everything
    # between FOO and BAR lines
    # NOT necessarily inside foo bar block

    regexp: \d+

    code:  <<CODE
    for my $i (@{captures()}) {     
        print "#", $i->[0], "\n";   
    }                               
    print "# FOO/BAR end"

    CODE

Output:

    # foo/bar start
    # 1
    # 2
    # 3
    # 100
    # foo/bar end

    # FOO/BAR start
    # 100
    # 10
    # 20
    # 30
    # FOO/BAR end
    

## Restoring search context
        
And finally to restore search context use \`reset\_context:' statement.

Input text:

    hello
    foo
        hello
        hello
    bar


DSL code:

    between foo bar

    # all check expressions here
    # will be applied to the chunks
    # between /foo/ ... /bar/

    hello       # should match 2 times

    # if you want to get back to an original search context
    # just say reset_context:

    reset_context:
    hello       # should match three times


## Range expressions caveats

Range expressions can't verify continuous lists.

That means range expression only verifies that there are _some set_ of lines inside some range.
It is not necessary should be continuous.

Example.

Input text:

    
    foo
        1
        a
        2
        b
        3
        c
    bar


DSL code:

    between: foo bar
        1
        code: print capture()->[0], "\n"
        2
        code: print capture()->[0], "\n"
        3
        code: print capture()->[0], "\n"

Output:

        1 
        2 
        3 

If you need check continuous sequences checks use text blocks.

# Experimental features

Below is highly experimental features purely tested. You may use it on your own risk! ;)

## Streams

Streams are alternative for captures. Consider following example.

Input text:

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

DSL code:


    begin:
    
        foo
    
            regexp: (\S+)
            code: print '#', ( join ' ', map {$_->[0]} @{captures()} ), "\n"
    
            regexp: (\S+)
            code: print '#', ( join ' ', map {$_->[0]} @{captures()} ), "\n"
    
            regexp: (\S+)
            code: print '#', ( join ' ', map {$_->[0]} @{captures()} ), "\n"
    
    
        bar
    
    end:
    
Output:


    # a 1 0
    # b 2 00
    # c 3 000


Notice something interesting? Output direction has been inverted.

The reason for this is outhentix check expression works in "line by line scanning" mode 
when text input gets verified line by line against given check expression. 

Once all lines are matched they get dropped into one heap without preserving original "group context". 

What if we would like to print all matching lines grouped by text blocks they belong to?

As it's more convenient way ...

This is where streams feature comes to rescue.

Streams - are all the data successfully matched for given _group context_. 

Streams are _applicable_ for text blocks and range expressions.

Let's rewrite last example.

DSL code:

    begin:

        foo
            regexp: \S+
            regexp: \S+
            regexp: \S+
        bar

        code:  <<CODE
            for my $s (@{stream()}) {           
                print "# ";                     
                for my $i (@{$s}){              
                    print $i;                   
                }                               
                print "\n";                     
            }

    CODE

    end:


Stream function returns an arrays of _streams_. Every stream holds all the matched lines for given _logical block_.

Streams preserve group context. Number of streams relates to the number of successfully matched groups.

Streams data presentation is much closer to what was originally given in text input:

Output:

    # foo a b  c    bar
    # foo 1 2  3    bar
    # foo 0 00 000  bar


Stream could be specially useful when combined with range expressions of _various_ ranges lengths.

For example.

Input text:


    foo
        2
        4
        6
        8
    bar

    foo
        1
        3
    bar

    foo
        0
        0
        0
    bar


DSL code:

    between: foo bar

    regexp: \d+

    code:  <<CODE
        for my $s (@{stream()}) {           
            print "# ";                     
            for my $i (@{$s}){              
                print $i;                   
            }                               
            print "\n";                     
        }
    
    CODE

Output:

    
    # 2 4 6 8
    # 1 3
    # 0 0 0


# Author

[Aleksei Melezhik](mailto:melezhik@gmail.com)

# Home page

https://github.com/melezhik/outhentix-dsl

# COPYRIGHT

Copyright 2015 Alexey Melezhik.

This program is free software; you can redistribute it and/or modify it under the same terms as Perl itself.

# See also

Alternative outhentix DSL introduction could be found here - [intro.md](https://github.com/melezhik/outhentix-dsl/blob/master/intro.md)

# Thanks

* To God as the One Who inspires me to do my job!


