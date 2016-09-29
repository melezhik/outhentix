use v6;

use Outhentix::DSL::Context::Range;
use Outhentix::DSL::Context::TextBlock;
use Outhentix::DSL::Context::Default;
use JSON::Tiny;

use MONKEY-SEE-NO-EVAL;
use File::Temp;

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
  has Str $.text;
  has Int $.check-max-len = 40;
  has %.languages;
  has @.stream;
  has Int $.debug-mode = 0;
  has Str $.cache-dir = %*ENV<OTX_CACHE_DIR> ?? %*ENV<OTX_CACHE_DIR>.Str !! '/tmp';

  method captures {
    @!captures;
  }

  method !add-result ( %item ) {
    %item<type> = 'check-expression';
    @!results.push: %item;
  }

  method !debug ($msg) {
    say $msg;
  }

  method !reset-context {
  
      @!current-context = @!original-context;
  
      self!debug('reset search context') if $!debug-mode >= 2;
  
      $!context-modificator = Outhentix::DSL::Context::Default.new();
  
  }

  method !create-context {
  
      return if $!has-context;

      my $i = 0;
  
      my @context = Array.new;
  
      for ($!text ?? $!text.lines !! [] ) -> $ll {

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

  method !handle-code (Str $code is copy) { 

    my $result;
  
    if $code ~~ s/^^\!(\w+)\s*$$// {
  
        my $language = $0;
      
        my ( $source-file, $filehandle ) = tempfile(:tempdir($!cache-dir),:!unlink);
      
        spurt $source-file, $code;
      
        my $ext-runner = $language eq 'bash' ?? "bash -c 'source " ~ $source-file ~ "'" 
        !!  ( %!languages{$language} || $language ) ~ ' ' ~ $source-file;
      
        $ext-runner ~= ' ' ~ '1>' ~ $source-file ~ '.out';
        $ext-runner ~= ' ' ~ '2>' ~ $source-file ~ '.err';
      
        self!debug("running shell: $ext-runner") if $!debug-mode >= 3;
  
        shell $ext-runner;
  
        self!debug("$language code OK. code: $code") if $!debug-mode >= 2;
      
        $result = slurp $source-file ~ '.out';
      
        
      } else {
  
        self!debug("running inline perl6: $code") if $!debug-mode >= 2;

        #my $b = (self but role :: { method eval ($c) { EVAL $c; self } });

        #$result = ($b.eval($code)||[]).join("\n");

        $result = (EVAL $code).join("\n");
  
        self!debug("perl6 code OK. code: $code") if $!debug-mode >= 2;
  
      }
  
    return $result;

  } # end of method



  method !handle-validator ($code) { 

    my @result = self!handle-code($code).lines;
    self!add-result({ status => @result[0], message => @result[1] });    

  }

  method !handle-generator ($code) { self.validate((self!handle-code($code))) }

  method !handle-within (Str $line) { 

    my $msg;

    if $!within-mode {
      $msg = $!last-check-status ?? "'" ~ self!short-string($!last-match-line) ~ "' match /$line/"
      !! "text match /$line/";
    }else{
        $msg = "text match /$line/";
    }

    $!within-mode = True;

    self!check-line($line, 'regexp', $msg);

    self!debug("within check DONE. >>> <<<$line>>>") if $!debug-mode >= 3;
  
  }

  method !handle-plain (Str $line) {
    self!handle-simple($line, 'default');
  }

  method !handle-regexp (Str $line) {
    self!handle-simple($line, 'regexp');
  }

  method !handle-simple (Str $l, Str $check-type) {
  
    my $msg;

    my $lshort =  self!short-string($l);
  
    my $reset-context = False;
  
    if $!within-mode {
  
        $!within-mode = False;

        $reset-context = True;
        
        $msg = $!last-check-status ?? "'" ~ self!short-string($!last-match-line) 
        ~ "'" ~ ' match ' ~ "'" ~ $lshort ~ "'" !! "text match '" ~ $lshort ~ "'";


    } else {
        $msg = $!block-mode ?? "[b] text match '$lshort'" !! "text match '$lshort'";
    }
  

    self!check-line($l, $check-type, $msg);
  
    self!reset-context if $reset-context;

    self!debug("$check-type check DONE. >>> <<<$l>>>") if $!debug-mode >= 3;

  }

  method !short-string (Str $l) {
  
      my $orig-l = $l;

      my $short-l = substr( $l, 0, $!check-max-len );

      $short-l ~~ s/\r//; $orig-l ~~ s/\r//;
  
      return $short-l le $orig-l ?? "$short-l ..." !! $orig-l;
  
  }

  method !reset-captures {
    @!captures = Array.new;
    ($!cache-dir ~ "/captures.json").IO.unlink if ($!cache-dir ~ "/captures.json").IO ~~ :e;

  }

  method !check-line ( Str $pattern, Str $check-type, Str $message ) {


    my $status = False;

    self!reset-captures;

    my @captures = Array.new;

    self!create-context;

    self!debug("[lookup] $pattern ...") if $!debug-mode >= 2;

    my @context-new = Array.new;

    # dynamic context
    my @dc = $!context-modificator.change-context(
      @!current-context,
      @!original-context, 
      @!succeeded,
      %*ENV<OTX_STREAM_DEBUG> ?? True !! False
    );

    @!succeeded = Array.new;

    self!debug("context modificator applied: " ~ ($!context-modificator.WHAT.perl)) if $!debug-mode >=2;

    if $!debug-mode >= 2 {
      for @dc -> $i { self!debug("[dc] " ~ $i[0]) } 
    }


    if $check-type eq 'default' {

        for @dc -> $c {

            my $ln = $c[0];

            next if $ln ~~ m/\#dsl_note:/;

            my $st = index($ln,$pattern);

            if $st.defined {
                $status = True;
                $!last-match-line = $ln;
                @!succeeded.push: $c;
            }
        }

    } elsif $check-type eq 'regexp' {


        for @dc -> $c {

            my $ln = $c[0];

            next if $ln eq ":blank_line";
            next if $ln ~~ m/\#dsl_note:/;

            my $matched = $ln.comb(/<mymatch=$pattern>/,:match)>>.<mymatch>;

            if $matched {
                @captures.push: [ $matched>>.Slip>>.Str ] if $matched>>.Slip>>.Str;
                $status = True;
                @!succeeded.push: $c;
                @context-new.push: $c if $!within-mode;
                $!last-match-line = $ln;
            }

        }
    }else {
        die "unknown check type: $check-type";
    }



    $!last-check-status = $status;

    if $!debug-mode >= 2 {

        my $i = -1;
        my $j = -1;

        for @captures -> $cpp {
            $i++;
            for @($cpp) -> $cp {
                $j++;
                self!debug("CAP[$i,$j]: $cp");
            }
            $j=0;
        }

        for @!succeeded -> $s {
            self!debug("SUCC: $s[0]");
        }
    }

    @!captures = @captures;

    spurt ($!cache-dir ~ '/captures.json' ), to-json(@!captures);

    self!debug("CAPTURES saved at " ~ $!cache-dir ~ '/captures.json' ) if $!debug-mode >= 1;

    # update context
    if  $!within-mode and $status {
        @!current-context = @context-new;
        self!debug('within mode: modify search context to: ' ~ (@context-new.perl)) if $!debug-mode >= 2;
    } elsif $!within-mode and ! $status {
        @!current-context = Array.new; # empty context if within expression has not matched
        self!debug('within mode: modify search context to: ' ~ (@context-new.perl)) if $!debug-mode >= 2;
    }

    self!add-result({ status => $status , message => $message });

    $!context-modificator.update-stream(
      @!current-context, 
      @!original-context, 
      @!succeeded, 
      @!stream,
      %*ENV<OTX_STREAM_DEBUG> ?? True !! False
    );

    return $status;

  }
    
  method validate ($check-list) {

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

        } elsif $block-type && ( $l ~~ s/\\\s*$// or $here-str-mode ) { # multiline block

           # this is multiline block or here string, 
           # accumulate lines until meet line not ending with '\' ( for multiline blocks )
           # or here string end marker ( for here stings )
  
           self!debug("\tpush $l to $block-type ...") if $!debug-mode  >= 2;

           @multiline-block.push: $l;
  
      
        } elsif $l ~~ m/^\s*begin\:\s*$/ { # begining  of the text block

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;
 
            die "you can't switch to text block mode when within mode is enabled" if $!within-mode;

            $!context-modificator = Outhentix::DSL::Context::TextBlock.new();

            self!debug('text block start') if $!debug-mode >= 2;

            $!block-mode = True;

            @!succeeded = Array.new;

        } elsif ($l ~~ m/^\s*end\:\s*$/) { # end of the text block

            $!block-mode = False;

            self!reset-context();

            self!debug('text block end') if $!debug-mode >= 2;

        } elsif $l ~~ m/^\s*reset_context\:\s*$/ {

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            self!reset-context();

        } elsif $l ~~ m/^\s*assert\:\s+(\d+)\s+(.*)/ {

            my $status = $0; my $message = $1;

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            self!debug("assert found: $status | $message") if $!debug-mode >= 2;

            $status = False if $status eq 'false'; # ruby to perl6 conversion

            $status = True if $status eq 'true'; # ruby to perl6 conversion

            self!add-result({ status => $status , message => $message });

        } elsif $l ~~ m/^\s*between\:\s+(.*)/ { # range context

                        
            die "you can't switch to range context mode when within mode is enabled" if $!within-mode;
            die "you can't switch to range context mode when block mode is enabled" if $!block-mode;

            my $pattern = $0.Str;

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            my ($a, $b) = split /\s+/, $pattern;
        
            $a ~~ s:g/\s//; $b ~~ s:g/\s//;
        
            $a ||= '.*';
            $b ||= '.*';
        
            $!context-modificator = Outhentix::DSL::Context::Range.new( bound-left => $a , bound-right => $b );


        } elsif $l ~~ m/^\s* ( 'code' | 'generator'| 'validator' ) \: \s* (.*) /  {

            my $my-block-type = $0;

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            my $code = $1;

            if $code ~~ s/.*\\\s*$// {

                 # this is multiline block, accumulate lines until meet '\' line
                 $block-type = $my-block-type;
                 @multiline-block.push: $code;

                 self!debug("$block-type block start.") if $!debug-mode  >= 2;

            } elsif $code ~~ s/'<<' (\S+) // {

                $block-type = $my-block-type;

                $here-str-mode = True;

                $here-str-marker = $0;

                self!debug("$block-type block start. heredoc marker: $here-str-marker") if $!debug-mode  >= 2;


            } else {

                self!debug("one-line $my-block-type found: $code") if $!debug-mode  >= 2;

                self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

                self!"handle-$my-block-type"($code.Str);

            }

        } elsif $l ~~ /^\s*regexp\:\s*(.*)/ { # `regexp' line

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            my $re = $0;

            self!handle-regexp($re.Str);

        } elsif $l ~~ /^\s*within\:\s*(.*)/ {

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            die "you can't switch to within mode when text block mode is enabled" if $!block-mode;

            my $re = $0;

            self!handle-within($re.Str);

        } else { # `plain string' line

            self!flush-multiline-block( $block-type, @multiline-block) if $block-type;

            $l ~~ s/\s+\#.*//; 

            $l ~~ s/^\s+//;

            self!handle-plain($l);

        }
    }

      self!flush-multiline-block( $block-type, @multiline-block) if $block-type;
  
  }

  method  !flush-multiline-block ($block-type is rw, @multiline-block) {

    my $name = "handle-" ~ $block-type; 

    self!debug("$block-type block end.") if $!debug-mode  >= 2;

    self!"$name"(@multiline-block.join("\n"));
  
    # flush mulitline block data:
    $block-type = Nil;
    @multiline-block = Array.new;


  }
}



