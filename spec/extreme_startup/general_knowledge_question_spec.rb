require 'spec_helper'
require 'extreme_startup/question_factory'

module ExtremeStartup
  describe GeneralKnowledgeQuestion do
    let(:question) { GeneralKnowledgeQuestion.new(Player.new) }

    it "converts to a string" do
      question.as_text.should =~ /wh.+/
    end
  end
end
