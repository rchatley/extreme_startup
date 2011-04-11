require_relative 'question'

module ExtremeStartup
  class QuestionFactory
    def next_question
      return AdditionQuestion.new
      MultiplicationQuestion
      SubtractionQuestion
      PowerQuestion
      PrimeQuestion what is the 4th prime number?
      FibonacciQuestion what is the 3rd Fib number?
      SillyQuestion "Who is the Prime Minister of Great Britain?"
      
    end
  end
end