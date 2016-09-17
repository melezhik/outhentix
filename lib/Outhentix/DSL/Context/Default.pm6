use v6;

class Outhentix::DSL::Context::Default { 

  method change-context (@current-context, @original-context, @succeeded ) {
    @current-context    
  }

  method update-stream (@current-context, @original-context, @succeeded , %stream ) {
    return
  }
};

