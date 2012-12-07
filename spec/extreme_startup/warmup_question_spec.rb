require 'spec_helper'
require 'extreme_startup/player'

module ExtremeStartup
  describe Question do
    let(:player) { Player.new({"name" => "S\u00E9bastian".force_encoding("UTF-8"),
                               "url" => "http://127.0.0.1:8080", }) }
    let(:question) {
      question = WarmupQuestion.new(player)
      question.answer = "S\u00E9bastian".force_encoding("ASCII-8BIT")
      question
    }

    context "when displaying response with an answer encoded into ASCII-8BIT" do
      it "should not raise error" do
        lambda { "For player #{:player}\n#{question.display_result}" }.should_not raise_error
      end
    end

  end
end

