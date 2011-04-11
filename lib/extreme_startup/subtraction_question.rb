module ExtremeStartup
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
end