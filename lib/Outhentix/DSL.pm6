use v6;

use Outhentix::DSL::Context::Range;
use Outhentix::DSL::Context::TextBlock;
use Outhentix::DSL::Context::Default;
use Outhentix::DSL::Error::UnterminatedBlock;

class Outhentix::DSL {

  has @.results;
  has @.original-context;
  has @.current-context;
  has $.context-modificator = Outhentix::DSL::Context::Default.new();
  has Bool $.has-context = False;
  has Bool $.within-mode = False;
  has Bool $.block-mode = False;
  has @.succeeded;
  has @.captures;
  has Str $.last-match-line;
  has Bool $.last-check-status;
  has Str $.output;
  has Int $.match-l = 40;
  has %.languages;
  has %.stream;
  has Int $.debug-mode = 0;

  method !add-result (%item) {
    %item<type> = 'check_expression';
    @!results.push: %item;
  }

  method !debug ($msg) {
    say $msg;
  }

  method !reset-context {
  
      @!current-context = @!original-context;
  
      self!debug('reset search context') if $!debug-mode >= 2;
  
      $.context-modificator = Outthentic::DSL::Context::Default.new();
  
  }

  method !create-context {
  
      return if $!has-context;
  
      my $i = 0;
  
      my @context = Array.new;
  
      for $!output.lines -> $ll {

          my $l = $ll.chomp;

          $i++;

          $l=":blank_line" unless $l ~~ m/\S/;

          @context.push: [$l, $i];
  
          self!debug("[oc] [$l, $i]") if $!debug-mode >= 2;
  
      }
  
      @!original-context = @!current-context = @context;
  
  
      self!debug('context populated') if $!debug-mode >= 2;
  
  
      $!has-context = True;
  
  
  }

  method !handle-code ($code) { }

  method !handle-validator ($code) { }

  method !handle-generator ($code) { }

  method !handle-regexp ($re) { }

  method !handle-within ($re) { }

  method !handle-plain ($str) { }

  method validate ($check-list) {

    my @lines;
    my $block-type;
    my @multiline-block = Array.new;
    my $here-str-mode = False;
    my $here-str-marker;

    return unless $check-list;

    LINE: for $check-list.lines -> $ll {

        my $l = $ll.chomp;

        self!debug("[type] " ~ ($block-type || 'not set') ) if $!debug-mode >= 2;
        self!debug("[dsl] $l") if $!debug-mode >= 2;

        next LINE unless $l ~~ m/\S/;    # skip blank lines

        next LINE if $l ~~ m/^\s*\#.*/;  # skip comments
        
        if $here-str-mode && $l ~~ s/^$here-str-marker\s*$// {

          $here-str-mode = False; 

          self!debug("here string mode off") if $!debug-mode >= 2;

        } elsif $block-type { # multiline block

             if ( $l ~~ s/\\\s*$// or $here-str-mode ) {

               # this is multiline block or here string, 
               # accumulate lines until meet line not ending with '\' ( for multiline blocks )
               # or here string end marker ( for here stings )

               self!debug("\tpush $l to $block-type ...") if $!debug-mode  >= 2;
               @multiline-block.push: $l;

             } else {

                # the end of multiline block or here string

                my $name = "handle-"; 
                $name ~= $block-type;
                @multiline-block.push: $l;

                self!debug("$block-type block end.") if $!debug-mode  >= 2;

                self!"$name"(@multiline-block.join(''));

                # flush mulitline block data:
                $block-type = Nil;
                @multiline-block = Array.new;

            }
      
        } elsif $l ~~ m/^\s*begin:\s*$/ { # begining  of the text block

            die "you can't switch to text block mode when within mode is enabled" if $!within-mode;

            $!context-modificator = Outthentic::DSL::Context::TextBlock.new();

            self!debug('begin block start') if $!debug-mode >= 2;

            $!block-mode = True;

            @!succeeded = Array.new;

        } elsif ($l ~~ m/^\s*end:\s*$/) { # end of the text block

            $!block-mode = False;

            self!reset-context();

            self!debug('text block end') if $!debug-mode >= 2;

        }

        if $l ~~ m/^\s*reset_context:\s*$/ {

            self!reset-context();

        } elsif ($l ~~ m/^\s*assert:\s(\S+)\s+(.*)$/) {

            my $status = $0; my $message = $1;

            self!debug("assert found: $status , $message") if $!debug-mode >= 2;

            $status = False if $status eq 'false'; # ruby to perl6 conversion

            $status = True if $status eq 'true'; # ruby to perl6 conversion

            self!add-result({ status => $status , message => $message });

        } elsif ($l ~~ m/^\s*between:\s+(.*)/) { # range context
            
            $!context-modificator = Outthentic::DSL::Context::Range.new($0);

            die "you can't switch to range context mode when within mode is enabled" if $!within-mode;

            die "you can't switch to range context mode when block mode is enabled" if $!block-mode;
        } elsif $l ~~ m/^\s*(code|generator|validator):\s*(.*)/  {

            $block-type = $0;

            my $code = $1;

            if $code ~~ s/\\\s*$// {

                 # this is multiline block, accumulate lines until meet '\' line

                 @multiline-block.push: $code;

                 self!debug("$block-type block start.") if $!debug-mode  >= 2;

            } elsif $code ~~s/<<(\S+)// {

                $here-str-mode = True;

                $here-str-marker = $0;

                self!debug("$block-type block start. heredoc marker: $here-str-marker") if $!debug-mode  >= 2;


            } else {

                $block-type = Nil;

                self!"handle-$block-type"($code);

            }

        } elsif $l ~~ /^\s*regexp:\s*(.*)/ { # `regexp' line

            my $re = $0;

            self!handle-regexp($re);

        } elsif $l ~~ /^\s*within:\s*(.*)/ {

            die "you can't switch to within mode when text block mode is enabled" if $!block-mode;

            my $re = $0;

            self!handle-within($re);

        } else { # `plain string' line

            $l ~~ s/\s+\#.*//; 

            $l ~~ s/^\s+//;

            self!handle-plain($l);

        }
    }

    if $block-type.defined {
      Outhentix::DSL::Error::UnterminatedBlock.new( message => 
        "Unterminated multiline block found. Last line: " ~ ( @multiline-block.pop )
      ).throw;
    }
  
  }
  
}



