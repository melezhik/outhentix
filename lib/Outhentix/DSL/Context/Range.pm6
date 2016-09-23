use v6;

class Outhentix::DSL::Context::Range {

  has %.chains;
  has $.bound-left;
  has $.bound-right;
  has @.ranges;
  has %.bad-ranges;

  method change-context ( @current-context, @original-context, @succeeded ) {

    my @new-ctx = Array.new;

    my @chunk = Array.new;

    my $inside = False;

    my $a-index;
    my $b-index;

    SUCC: for @current-context -> $c {

        my $br = $!bound-right;

        if $inside and not $c[0] ~~ m/{$br}/ {
            @chunk.push: $c;
            next SUCC;
        }

        if $inside and $c[0] ~~ m/{$br}/ {

            @new-ctx.push: @chunk;

            @new-ctx.push: ["#dsl_note: end range"];

            @chunk = Array.new;

            $inside = False;

            $b-index = $c[1];

            if ! %!chains{$a-index} {
                %!chains{$a-index} = Array.new;
                @!ranges.push: [$a-index, $b-index];
            }

            next SUCC;

        }


        my $bl = $!bound-left;

        if $c[0] ~~ m/{$bl}/ and not %!bad-ranges{$c[1]}:exists {
            $inside = True;
            $a-index = $c[1];
            @chunk.push: ["#dsl_note: start range"];

            next SUCC;

        }

    }

    return @new-ctx;

  }


};

