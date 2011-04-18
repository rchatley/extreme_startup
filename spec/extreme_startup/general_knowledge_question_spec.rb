require 'spec_helper'
require 'extreme_startup/question_factory'

module ExtremeStartup
  describe GeneralKnowledgeQuestion do
    let(:question) { GeneralKnowledgeQuestion.new }
    
    it "converts to a string" do
      question.to_s.should =~ /wh.+/
    end
  end
end
