require 'spec_helper'
require 'extreme_startup/quiz_master'

module ExtremeStartup
  describe RateController do
    let(:controller) { RateController.new }
    
    it "delays 5 seconds after correct answers" do
      controller.delay_before_next_request(FakeAnswer.new(:correct)).should == 5
    end
    
    it "delays 10 seconds after wrong answers" do
      controller.delay_before_next_request(FakeAnswer.new(:wrong)).should == 10
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
