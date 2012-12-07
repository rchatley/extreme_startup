require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe FibonacciQuestion do
    let(:question) { FibonacciQuestion.new(Player.new, 18, nil) }
    
    it "converts to a string" do
      question.as_text.should =~ /what is the 22nd number in the Fibonacci sequence/i
    end
    
    context "when the numbers are known" do
      let(:question) { FibonacciQuestion.new(Player.new, 2, nil) }
        
      it "converts to the right string" do
        question.as_text.should =~ /what is the 6th number in the Fibonacci sequence/i
      end
      
      it "identifies a correct answer" do
        question.answered_correctly?("8").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("5").should be_false
      end
    end
    
    context "when the numbers are large" do
      let(:question) { FibonacciQuestion.new(Player.new, 200, nil) }

      it "converts to the right string" do
        question.as_text.should =~ /what is the 204th number in the Fibonacci sequence/i
      end

      it "identifies a correct answer" do
        question.answered_correctly?("1923063428480944139667114773918309212080528").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("1923063428480957210245803843555347568525312").should be_false
      end
    end
    
  end
end
