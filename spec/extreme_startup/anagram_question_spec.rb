require 'spec_helper'
require 'extreme_startup/question_factory'
require 'extreme_startup/player'

module ExtremeStartup
  describe AnagramQuestion do
    let(:question) { AnagramQuestion.new(Player.new) }

    it "converts to a string" do
      question.as_text.should =~ /which of the following is an anagram of "\w+":/i
    end

    context "when the words are known" do
      let(:question) { AnagramQuestion.new(Player.new, "listen", "inlets", "enlists", "google", "banana") }

      it "converts to the right string" do
        question.as_text.should =~ /which of the following is an anagram of "listen": /i
      end

      it "identifies a correct answer" do
        question.answered_correctly?("inlets").should be_true
      end

      it "identifies an incorrect answer" do
        question.answered_correctly?("enlists").should be_false
      end
    end

  end
end
