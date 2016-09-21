# SYNOPSIS

Outhentix::DSL is a future replacement of Outthentic::DSL. I am going to rewrite all from the 
scratch using Perl6. Meanwhile follow [Outthentic::DSL](https://github.com/melezhik/outthentic-dsl)
to understand what Outhentix is.

[![Build Status](https://travis-ci.org/melezhik/outhentix-dsl.svg)](https://travis-ci.org/melezhik/outhentix-dsl)

# INSTALL
    
    $ panda install Outhentix::DSL

# Developing

    $ git clone https://travis-ci.org/melezhik/outhentix-dsl 
    $ cd outhentix-dsl
    $ OTX_DEBUG=2 prove -e 'perl6 -I lib' -v -r t/
    $ panda --force install .

# Environment variables

I'll document these variables later. Here is just a list:

* OTX_DEBUG (1,2,3,4)
* OTX_STREAM_DEBUG (set|not set)


# Author

[Alexey Melezhik](mailto:melezhik@gmail.com)
