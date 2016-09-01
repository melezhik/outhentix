# SYNOPSIS

Outhentix is a future replacement of Outthentic::DSL. I am going to rewrite all from the 
scratch using Perl6. Meanwhile follow [Outthentic::DSL](https://github.com/melezhik/outthentic-dsl)
to understand what Outhentix is.

[![Build Status](https://travis-ci.org/melezhik/outhentix-dsl.svg)](https://travis-ci.org/melezhik/outhentix-dsl)

# INSTALL
    
    $ panda install Outhentix

# Developing

    $ git clone https://travis-ci.org/melezhik/outhentix-dsl 
    $ cd outhentix-dsl
    $ OTX_DEBUG=2 prove -e 'perl6 -I lib' -v -r t/
    $ panda --force install .

# Author

[Alexey Melezhik](mailto:melezhik@gmail.com)
