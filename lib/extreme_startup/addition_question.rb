module ExtremeStartup
  class AdditionQuestion
    def initialize
      @n1, @n2 = rand(5), rand(5)
    end
  
    def answered_correctly?(answer) 
      return correct_answer.to_s.strip == answer.to_s.strip
    end

    def to_s
      return "what is #{@n1} plus #{@n2}"
    end

  private
    
    def correct_answer
      @n1 + @n2
    end
  
  end
end