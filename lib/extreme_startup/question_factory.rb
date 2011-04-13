module ExtremeStartup
  class Question
    def answered_correctly?(answer) 
      correct_answer.to_s.downcase.strip == answer.to_s.downcase.strip
    end
  end
  
  class BinaryMathsQuestion < Question
    def initialize(*numbers)
      if numbers.any?
        @n1, @n2 = *numbers
      else
        @n1, @n2 = rand(5), rand(5)
      end
    end
  end
  
  class AdditionQuestion < BinaryMathsQuestion
    def to_s
      "what is #{@n1} plus #{@n2}"
    end
  private  
    def correct_answer
      @n1 + @n2
    end
  end
  
  class SubtractionQuestion < BinaryMathsQuestion 
    def to_s
      "what is #{@n1} minus #{@n2}"
    end
  private
    def correct_answer
      @n1 - @n2
    end
  end
  
  class MultiplicationQuestion < BinaryMathsQuestion 
    def to_s
      "what is #{@n1} multipled by #{@n2}"
    end
  private
    def correct_answer
      @n1 * @n2
    end
  end
  
  class PowerQuestion < BinaryMathsQuestion 
    def to_s
      "what is #{@n1} to the power of #{@n2}"
    end
  private
    def correct_answer
      @n1 ** @n2
    end
  end
  
  class FibonacciQuestion < BinaryMathsQuestion 
    def to_s
      n = @n1 + 4
      "what is the #{n}th number in the Fibonacci sequence"
    end
  private
    def correct_answer
      n = @n1 + 4
      root5 = Math.sqrt(5)
      phi = 0.5 + root5/2
      Integer(0.5 + phi**n/root5)
    end
  end
  
  class GeneralKnowledgeQuestion < Question
    class << self
      def question_bank
        [
          ["who is the Prime Minister of Great Britain", "David Cameron"],
          ["which city is the Eiffel tower in", "Paris"],
          ["what is the standard unit of beer served in British pubs", "pint"],
          ["what colour is a banana", "yellow"],
          ["who played James Bond in the film Dr No", "Sean Connery"]
        ]
      end
    end
    
    def initialize
      question = GeneralKnowledgeQuestion.question_bank.shuffle.first
      @question = question[0]
      @answer = question[1]
    end
    
    def to_s
      @question
    end
    
    def correct_answer
      @answer
    end
  end
  
  class QuestionFactory
    attr_reader :round
    
    def initialize
      @round = 0
      @question_types = [AdditionQuestion, MultiplicationQuestion, SubtractionQuestion, PowerQuestion, FibonacciQuestion, GeneralKnowledgeQuestion]
    end
    
    def next_question
      available_question_types = @question_types[0..@round]
      available_question_types.shuffle.first.new
    end
    
    def advance_round
      @round += 1
    end
    
  end
end