use v6;


use Outhentix::Context;

class Outhentix {

  has Array @.results;
  has Array @.original_context;
  has Array @.current_context;
  has Outhentix::Context $.context_modificator;

}


#`{

    my $class = shift;
    my $output = shift;
    my $opts = shift || {};

    bless {
        results => [],
        original_context => [],
        current_context => [],
        context_modificator => Outthentic::DSL::Context::Default->new(),
        has_context => 0,
        succeeded => [],
        captures => [],
        within_mode => 0,
        block_mode => 0,
        last_match_line => undef,
        last_check_status => undef,
        debug_mod => 0,
        output => $output||'',
        match_l => 40,
        stream => {},
        languages => {},
        %{$opts},
    }, __PACKAGE__;


}


