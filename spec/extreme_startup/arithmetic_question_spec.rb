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

  describe GeneralArithmeticQuestion do
    let(:question) { GeneralArithmeticQuestion.new(Player.new) }
    
    it "yields 60 points when answered correctly" do
      question.points.should == 60
    end
    
    context "when numbers and operators are known" do
      let(:question) { GeneralArithmeticQuestion.new(Player.new, 12, 'plus', 3, 'times', 4, 'plus', 5) }
      
      it "converts to a string" do
        question.as_text.should =~ /what is 12 plus 3 times 4 plus 5/      
      end

      it "identifies a correct answer" do
        question.answered_correctly?("29").should be_true
      end

    end

    context "when numbers and operators are not known" do
      let(:question) { GeneralArithmeticQuestion.new(Player.new) }

      it "generates a random expression" do
        question.as_text.should =~ /what is (\d+ (plus|minus|times))+ \d+/
      end

    end
  end
end
