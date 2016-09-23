use v6;

class Outhentix::DSL::Context::Range {

  has %.chains;
  has $.bound-left;
  has $.bound-right;
  has @.ranges;
  has %.bad-ranges;


  method change-context ( @current-context, @original-context, @succeeded ) {

    my @new-ctx = Array.new;

    my $inside = False;

    my $a-index;
    my $b-index;

    my $bl = $!bound-left;
    my $br = $!bound-right;

    #say "bound-left: $bl";
    #say "bound-right: $br";

    SUCC: for @current-context -> $c {

        if $inside and $c[0] ~~ m/$br/ {

            @new-ctx.push: $c;

            @new-ctx.push: ["#dsl_note: end range ($br) . last element - {@new-ctx[*-2][0]}"];

            #say "end range - $c";

            $inside = False;

            $b-index = $c[1];

            if ! %!chains{$a-index} {
                %!chains{$a-index} = Array.new;
                @!ranges.push: [$a-index, $b-index];
            }

            next SUCC;
        } 

        if $inside {

            #say "inside range - $c";

            @new-ctx.push: $c;

        } 

        if $c[0] ~~ m/$bl/ and not %!bad-ranges{$c[1]}:exists {

            #say "start range - $c";

            $inside = True;
            $a-index = $c[1];

            @new-ctx.push: $c;

            @new-ctx.push: ["#dsl_note: start range ($bl)"];

      }

    }

    #say @new-ctx;

    return @new-ctx;

  }

  method update-stream (@current-context, @original-context, @succeeded , @stream, $debug-mode = False ) {
    return
  }


};

