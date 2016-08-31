use v6;


use Outhentix::Context;
use Outhentix::DSL;

class Outhentix {

  has Array @.results;
  has Array @.original-context;
  has Array @.current-context;
  has Outhentix::Context $.context-modificator;
  has Bool $.has-context = False;
  has Array @.succeed;
  has Array @.captures;
  has Str $.last-match-line;
  has Bool $.last-check-status;
  has Bool $.debug-mode = False;
  has Str $.output;
  has Int $.match-l = 40;
  has Hash $.languages;
  has Hash $.stream;
  has Int $.debug-mod = 0;

  method validate ($check-list) {
    return 1;
  }


  method !add-result (%item) {
    %item<type> = 'check_expression';
    @!results.push: %item;
  }

  method !add-debug-result (%item) {
    %item<type> = 'debug';
    @!results.push: %item;
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
  
          self!add-debug-result("[oc] [$l, $i]") if $!debug-mod >= 2;
  
      }
  
      @!original-context = @!current-context = @context;
  
  
      self!add-debug-result('context populated') if $!debug-mod >= 2;
  
  
      $!has-context = True;
  
  
  }
  
}



