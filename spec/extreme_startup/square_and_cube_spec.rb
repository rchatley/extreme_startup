require 'spec_helper'
require 'extreme_startup/question_factory'

module ExtremeStartup
  describe SquareCubeQuestion do
    let(:question) { SquareCubeQuestion.new }
    
    it "converts to a string" do
      question.as_text.should =~ /which of the following numbers is both a square and a cube: (\d+, )+(\d+)/i
    end
    
    context "when the numbers are known" do
      let(:question) { SquareCubeQuestion.new(62, 63, 64) }
        
      it "converts to the right string" do
        question.as_text.should =~ /which of the following numbers is both a square and a cube: 62, 63, 64/i
      end
            
      it "identifies a correct answer" do
        question.answered_correctly?("64").should be_true
      end
           
      it "identifies an incorrect answer" do
        question.answered_correctly?("63").should be_false
      end
    end
    
    context "when there are multiple numbers in the answer" do
      let(:question) { SquareCubeQuestion.new(64, 65, 729) }

      it "identifies a correct answer" do
        question.answered_correctly?("64, 729").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("64").should be_false
      end
    end
      
  end
end
