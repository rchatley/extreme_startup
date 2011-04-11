module ExtremeStartup
  class Question
    def initialize(a,b)
      @n1 = a
      @n2 = b
    end
  
    def answered_correctly(answer) 
      correct_answer = @n1 + @n2
      return correct_answer.to_s.strip == answer.to_s.strip
    end
  
    def to_s
      return "what is #{@n1} plus #{@n2}"
    end
  end
end