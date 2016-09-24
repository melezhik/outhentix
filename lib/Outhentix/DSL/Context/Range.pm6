use v6;

class Outhentix::DSL::Context::Range {

  has $.bound-left;
  has $.bound-right;
  has %.chains;
  has %.seen;
  has @.ranges;
  has %.bad-ranges;


  method change-context ( @current-context, @original-context, @succeeded, $debug-mode = False ) {

    my @new-ctx = Array.new;

    my $inside = False;

    my $a-index;
    my $b-index;

    my $bl = $!bound-left;
    my $br = $!bound-right;

    say "bound-left: $bl" if $debug-mode;

    say "bound-right: $br" if $debug-mode;

    say "bad ranges: " ~ %!bad-ranges.keys.sort if $debug-mode;

    SUCC: for @current-context -> $c {

        if $inside and $c[0] ~~ m/$br/ {

            @new-ctx.push: ["#dsl_note: end range ($br) . last element - {@new-ctx[*-2][0]}"];

            say "end range - $c" if $debug-mode;

            $inside = False;

            $b-index = $c[1];

            if ! %!chains{$a-index} {
                %!chains{$a-index} = Array.new;
                @!ranges.push: [$a-index, $b-index];
            }

            next SUCC;
        } 

        if $inside {

            say "inside range - $c" if $debug-mode;

            @new-ctx.push: $c;

        } 

        if $c[0] ~~ m/$bl/ and not %!bad-ranges{$c[1]}:exists {

            say "start range - $c" if $debug-mode;

            $inside = True;
            $a-index = $c[1];

            @new-ctx.push: ["#dsl_note: start range ($bl)"];

      }

    }

    say 'new context:' ~ "\n" ~ @new-ctx.perl if $debug-mode;

    return @new-ctx;

  }

  method update-stream (@current-context, @original-context, @succeeded , @stream, $debug-mode = False ) {

    my $inside = False;

    my %live-ranges = Hash.new;

    say "start update-stream ..." if $debug-mode;

    say "succeeded: " ~ (@succeeded) if $debug-mode;

    say "succeeded: " ~ "\n" ~ @succeeded if $debug-mode;
    say "chains: " ~ "\n" ~ %!chains if $debug-mode;
    say "ranges: " ~ "\n" ~ @!ranges if $debug-mode;
    say "bad ranges: " ~ %!bad-ranges.keys.sort if $debug-mode;


    for @succeeded -> $c {

       for @!ranges -> $r {

            my $a-index = $r[0];
            my $b-index = $r[1];

            if $c[1] > $a-index and $c[1] < $b-index  {
                %!chains{$a-index}.push: $c unless %!seen{$c[1]}++;
                %live-ranges{$a-index}=1;
            }

        }

    }

    say "updated chains: " ~ "\n" ~ %!chains if $debug-mode;
    say "live ranges: " ~ "\n" ~ %live-ranges.keys.sort if $debug-mode;

    @stream = Array.new;


    for %!chains.keys -> $cid {

      if %live-ranges{$cid}:exists {
        say "keep range: $cid ..." if $debug-mode;
        @stream.push: [ %!chains{$cid}.map: { $_[0] } ];
      } else {            
        say "delete range: $cid ..." if $debug-mode;
        %!chains{$cid}:delete;
        %!bad-ranges{$cid} = True;
      }

    }

    say "updated bad ranges: " ~ %!bad-ranges.keys.sort if $debug-mode;
    say "updated chains: " ~ "\n" ~ %!chains if $debug-mode;

    say 'current stream ...' ~ @stream.perl if $debug-mode;

  }


};

