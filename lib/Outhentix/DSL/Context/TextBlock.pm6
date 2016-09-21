use v6;

class Outhentix::DSL::Context::TextBlock { 

  has %.chains;

  method change-context ( @current-context, @original-context, @succeeded ) {

    my @new-ctx = Array.new;

    if  @succeeded {
       for @succeeded -> $c {
            @new-ctx.push: @original-context[$c[1]]; # reference to next one
        }
    } else{
        @new-ctx = @current-context; # if no succeeded items found return original context
    }

    @new-ctx;

  }

  method update-stream (@current-context, @original-context, @succeeded , %stream ) { 

    my @actual-chains = Array.new;

    if @succeeded {

       if ! %!chains { # chain initialization 
            for @succeeded -> $c {
                %!chains{$c[1]} = [$c];
                #%stream.push:  $c[1], [$c];
            }
       };


       for @succeeded -> $c {

            my $my-chain;

            for %!chains.keys -> $cid {
                if %!chains{$cid}[*-1][1] == $c[1]-1 {
                    $my-chain = $cid;
                    @actual-chains.push: $cid;
                }
            }
            # succeeded element belongs only to a ONE chain!
            %!chains{$my-chain}.push: $c if $my-chain; 
        }
    }

    # remove unsuccessfull chains

    %stream = Hash.new;

    for @actual-chains -> $cid {
        %stream{$cid} = %!chains{$cid};
    }
  }
  
};

