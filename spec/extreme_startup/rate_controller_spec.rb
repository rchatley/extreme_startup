require 'spec_helper'
require 'extreme_startup/quiz_master'

module ExtremeStartup
  describe RateController do
    let(:controller) { RateController.new }
        
    it "reduces delays after successive correct answers" do
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 4.9
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 4.8
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 4.7
    end
    
    it "enforces minimum delay between successive correct answers is one second" do
      1000.times { controller.delay_before_next_request(FakeAnswer.new(:correct)) }
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 1
    end
        
    it "increases delays after successive wrong answers" do
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 5.1
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 5.2
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 5.1
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 5.2
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 5.3
    end
    
    it "enforces maximum delay between successive wrong answers is 20 seconds" do
      1000.times { controller.delay_before_next_request(FakeAnswer.new(:wrong)) }
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 20
    end
    
    it "delays 20 seconds after error responses" do
      controller.delay_before_next_request(FakeAnswer.new(:error)).should == 20
    end
    
  end
  
  class FakeAnswer
    def initialize(result)
      @result = result
    end
    def was_answered_correctly
      @result == :correct
    end
    def was_answered_wrongly
      @result == :wrong
    end
  end
  
end
