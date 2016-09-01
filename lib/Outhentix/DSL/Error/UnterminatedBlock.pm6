class Outhentix::DSL::Error::UnterminatedBlock is Exception {
  has $.message;  
  method message() { $!message }
};
