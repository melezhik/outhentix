use v6;

class Outhentix::DSL::Context::TextBlock { 

  has %.chains;

  method change-context ( @current-context, @original-context, @succeeded ) {

    my @new-ctx = Array.new;

    if  @succeeded {
       for @succeeded -> $c {
            @new-ctx.push: @original-context[$c[1]] if @original-context[$c[1]].defined; # reference to the next one
        }
    } else{
        @new-ctx = @current-context; # if no succeeded items found return original context
    }

    @new-ctx;

  }

  method update-stream (@current-context, @original-context, @succeeded , %stream, $debug-mode = False ) { 

    my %actual-chains = Hash.new;

    say "start update-stream ..." if $debug-mode;

    say "succeeded: " ~ (@succeeded) if $debug-mode;

    my $chain-updated = False;

    if @succeeded {

       if ! %!chains { # chain initialization 
            for @succeeded -> $c {
                %!chains{$c[1]} = [$c];
            }
       };

       say 'old chains ...' if $debug-mode;

       say %!chains if $debug-mode;
 
       for @succeeded -> $c {


            CHAIN: for %!chains.keys.sort -> $cid {
                if %!chains{$cid}[*-1][1] == $c[1]-1 {
                    %actual-chains{$cid} = 1;
                    # succeeded element belongs only to a ONE chain!
                    %!chains{$cid}.push: $c;
                    $chain-updated = True; 
                    last CHAIN;
                }
            }
        }

       
       say 'new chains ...' if $debug-mode;

       say %!chains if $debug-mode;

    }

    # remove unsuccessfull chains


    say 'actual chains: ' ~ %actual-chains.keys.sort if $debug-mode;

    if $chain-updated {

      %stream = Hash.new;

      for %actual-chains.keys -> $cid {
          %stream{$cid} = %!chains{$cid};
      }
    }

   say 'current stream ...' if $debug-mode;

   %!chains = %stream;
 
   say %stream if $debug-mode;

  }
  
};

