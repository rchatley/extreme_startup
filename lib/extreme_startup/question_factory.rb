require 'set'
require 'prime'

module ExtremeStartup
  class Question
    class << self
      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s[0..7]
      end
    end
    
    def id
      @id ||= Question.generate_uuid
    end
    
    def to_s
      "#{id}: #{as_text}"
    end
    
    def answered_correctly?(answer) 
      correct_answer.to_s.downcase.strip == answer.to_s.downcase.strip
    end
    
    def points
      10
    end
  end
  
  class BinaryMathsQuestion < Question
    def initialize(*numbers)
      if numbers.any?
        @n1, @n2 = *numbers
      else
        @n1, @n2 = rand(20), rand(20)
      end
    end
  end
  
  class TernaryMathsQuestion < Question
    def initialize(*numbers)
      if numbers.any?
        @n1, @n2, @n3 = *numbers
      else
        @n1, @n2, @n3 = rand(20), rand(20), rand(20)
      end
    end
  end
  
  class SelectFromListOfNumbersQuestion < Question
    def initialize(*numbers)
      if numbers.any?
        @numbers = *numbers
      else
        size = rand(2)
        @numbers = random_numbers[0..size].concat(candidate_numbers.shuffle[0..size]).shuffle
      end
    end
    
    def random_numbers
      randoms = Set.new
      loop do
        randoms << rand(1000)
        return randoms.to_a if randoms.size >= 5
      end
    end
    
    def correct_answer
       @numbers.select do |x|
         should_be_selected(x)
       end.join(', ')
     end
  end
  
  class MaximumQuestion < SelectFromListOfNumbersQuestion
     def as_text
        "which of the following numbers is the largest: " + @numbers.join(', ')
      end
      def points
        40
      end
    private
      def should_be_selected(x)
        x == @numbers.max
      end

      def candidate_numbers
          (1..100).to_a
      end
    end
  
  class AdditionQuestion < BinaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2}"
    end
  private  
    def correct_answer
      @n1 + @n2
    end
  end
  
  class SubtractionQuestion < BinaryMathsQuestion 
    def as_text
      "what is #{@n1} minus #{@n2}"
    end
  private
    def correct_answer
      @n1 - @n2
    end
  end
  
  class MultiplicationQuestion < BinaryMathsQuestion 
    def as_text
      "what is #{@n1} multiplied by #{@n2}"
    end
  private
    def correct_answer
      @n1 * @n2
    end
  end

  class AdditionAdditionQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2} plus #{@n3}"
    end
    def points
      30
    end
  private  
    def correct_answer
      @n1 + @n2 + @n3
    end
  end
    
  class AdditionMultiplicationQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} plus #{@n2} multiplied by #{@n3}"
    end
    def points
      60
    end
  private  
    def correct_answer
      @n1 + @n2 * @n3
    end
  end
  
  class MultiplicationAdditionQuestion < TernaryMathsQuestion
    def as_text
      "what is #{@n1} multiplied by #{@n2} plus #{@n3}"
    end
    def points
      50
    end
  private  
    def correct_answer
      @n1 * @n2 + @n3
    end
  end
  
  class PowerQuestion < BinaryMathsQuestion 
    def as_text
      "what is #{@n1} to the power of #{@n2}"
    end
    def points
      20
    end
  private
    def correct_answer
      @n1 ** @n2
    end
  end
  
  class SquareCubeQuestion < SelectFromListOfNumbersQuestion 
    def as_text
      "which of the following numbers is both a square and a cube: " + @numbers.join(', ')
    end
    def points
      60
    end
  private
    def should_be_selected(x)
      is_square(x) and is_cube(x)
    end
    
    def candidate_numbers
        square_cubes = (1..100).map { |x| x ** 3 }.select{ |x| is_square(x) }
        squares = (1..50).map { |x| x ** 2 }
        square_cubes.concat(squares)
    end
    
    def is_square(x)
      (x % Math.sqrt(x)) == 0
    end
    
    def is_cube(x)
      (x % Math.cbrt(x)) == 0
    end
  end
  
  class PrimesQuestion < SelectFromListOfNumbersQuestion 
     def as_text
       "which of the following numbers are primes: " + @numbers.join(', ')
     end
     def points
       60
     end
   private
     def should_be_selected(x)
       Prime.prime? x
     end

     def candidate_numbers
       Prime.take(100)
     end
   end
  
  class FibonacciQuestion < BinaryMathsQuestion 
    def as_text
      n = @n1 + 4
      "what is the #{n}th number in the Fibonacci sequence"
    end
    def points
      50
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
          ["what currency did Spain use before the Euro", "peseta"],
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
    
    def as_text
      @question
    end
    
    def correct_answer
      @answer
    end
  end
  
  class QuestionFactory
    attr_reader :round
    
    def initialize
      @round = 1
      @question_types = [
        AdditionQuestion, 
        MaximumQuestion,
        MultiplicationQuestion, 
        SquareCubeQuestion,
        GeneralKnowledgeQuestion,
        PrimesQuestion,
        SubtractionQuestion,
        FibonacciQuestion,  
        PowerQuestion,
        AdditionAdditionQuestion,
        AdditionMultiplicationQuestion,
        MultiplicationAdditionQuestion
      ]
    end
    
    def next_question
      available_question_types = @question_types[0..(@round * 2 - 1)]
      available_question_types.shuffle.first.new
    end
    
    def advance_round
      @round += 1
    end
    
  end
end