require 'spec_helper'
require 'extreme_startup/question_factory'

module ExtremeStartup
  describe FibonacciQuestion do
    let(:question) { FibonacciQuestion.new }
    
    it "converts to a string" do
      question.as_text.should =~ /what is the \d+th number in the Fibonacci sequence/i
    end
    
    context "when the numbers are known" do
      let(:question) { FibonacciQuestion.new(2, nil) }
        
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
    
  end
end
