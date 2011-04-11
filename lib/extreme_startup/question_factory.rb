module ExtremeStartup
  class AdditionQuestion
    def initialize
      @n1, @n2 = rand(5), rand(5)
    end
  
    def answered_correctly?(answer) 
      correct_answer.to_s.strip == answer.to_s.strip
    end

    def to_s
      "what is #{@n1} plus #{@n2}"
    end

  private
    
    def correct_answer
      @n1 + @n2
    end
  end
  
  class SubtractionQuestion
    def initialize(*numbers)
      if numbers.any?
        @n1, @n2 = *numbers
      else
        @n1, @n2 = rand(5), rand(5)
      end
    end
    
    def answered_correctly?(answer) 
      correct_answer.to_s.strip == answer.to_s.strip
    end
    
    def to_s
      "what is #{@n1} minus #{@n2}"
    end
    
  private    
    def correct_answer
      @n1 - @n2
    end
  end
  
  class QuestionFactory
    attr_reader :round
    
    def initialize
      @round = 0
      @question_types = [AdditionQuestion, SubtractionQuestion]
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