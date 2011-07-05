require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe PowerQuestion do
    let(:question) { PowerQuestion.new(Player.new) }
    
    it "converts to a string" do
      question.as_text.should =~ /what is \d+ to the power of \d+/i
    end
    
    context "when the numbers are known" do
      let(:question) { PowerQuestion.new(Player.new, 2,3) }
        
      it "converts to the right string" do
        question.as_text.should =~ /what is 2 to the power of 3/i
      end
      
      it "identifies a correct answer" do
        question.answered_correctly?("8").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("9").should be_false
      end
    end
    
  end
end
