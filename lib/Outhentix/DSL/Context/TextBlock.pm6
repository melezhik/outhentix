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

  method update-stream (@current-context, @original-context, @succeeded , @stream, $debug-mode = False ) { 

    my %live-chains = Hash.new;

    say "start update-stream ..." if $debug-mode;

    say "succeeded: " ~ (@succeeded) if $debug-mode;

    if $debug-mode {
      say "doing chain initilization ... " if %!chains;
    }

    if @succeeded {

       if ! %!chains { # chain initialization 
            for @succeeded -> $c {
                %!chains{$c[1]} = [$c];
            }
       };

 
       say 'old chains ...' if $debug-mode;

       say %!chains if $debug-mode;

       for @succeeded -> $c {

            CHAIN: for %!chains.keys.sort({$^a <=> $^b}) -> $cid {
                next CHAIN if %live-chains{$cid};
                if %!chains{$cid}[*-1][1] == $c[1]-1 {
                    %live-chains{$cid} = True;
                    say "add node $c to chain Num $cid (" ~ %!chains{$cid}[*-1][0] ~ ")"  if $debug-mode;
                    %!chains{$cid}.push: $c;
                    last CHAIN;
                } elsif %!chains{$cid}[*-1][1] == $c[1] {
                    %live-chains{$cid} = True;
                    last CHAIN;
                }
                
            }

        }

    }

    say 'live chains IDs: ' ~ %live-chains.keys.sort({$^a <=> $^b}) if $debug-mode;

    @stream  = Array.new;


    # delete failed chains

    for %!chains.keys.sort({$^a <=> $^b}) -> $cid {
      if %live-chains{$cid}:exists {        
          @stream.push: [ %!chains{$cid}.map: { $_[0] } ]
      } else {
          say "delete chain: $cid ..." if $debug-mode;
          %!chains{$cid}:delete
      }
    }


   say 'actual chains: ' ~ "\n" ~ %!chains if $debug-mode;

   say 'current stream ...' ~ @stream.perl if $debug-mode;

  }
  
};

