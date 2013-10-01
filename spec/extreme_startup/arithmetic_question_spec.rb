require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup

  describe MinusQuestion do
    let(:question) { MinusQuestion.new(Player.new) }
    
    it "converts to a string" do
      question.as_text.should =~ /what is \d+ - \d+/i
    end
    
    context "when the numbers are known" do
      let(:question) { MinusQuestion.new(Player.new, 2,3) }
        
      it "converts to the right string" do
        question.as_text.should =~ /what is 2 - 3/i
      end
      
      it "identifies a correct answer" do
        question.answered_correctly?("-1").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("77").should be_false
      end
    end
    
  end

  describe PlusQuestion do
    let(:question) { PlusQuestion.new(Player.new) }
    
    it "converts to a string" do
      question.as_text.should =~ /what is \d+ \+ \d+/i
    end
    
    context "when the numbers are known" do
      let(:question) { PlusQuestion.new(Player.new, 2,3) }
        
      it "converts to the right string" do
        question.as_text.should =~ /what is 2 \+ 3/i
      end
      
      it "identifies a correct answer" do
        question.answered_correctly?("5").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("77").should be_false
      end
    end
    
  end

  describe MultQuestion do
    let(:question) { MultQuestion.new(Player.new) }
    
    it "converts to a string" do
      question.as_text.should =~ /what is \d+ \* \d+/i
    end
    
    context "when the numbers are known" do
      let(:question) { MultQuestion.new(Player.new, 2,3) }
        
      it "converts to the right string" do
        question.as_text.should =~ /what is 2 \* 3/i
      end
      
      it "identifies a correct answer" do
        question.answered_correctly?("6").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("77").should be_false
      end
    end
    
  end
end
