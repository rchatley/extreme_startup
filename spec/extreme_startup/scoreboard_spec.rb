require 'spec_helper'
require 'extreme_startup/scoreboard'

module ExtremeStartup
  describe Scoreboard do
    let(:scoreboard) { Scoreboard.new(false, nil) }
    
    describe "#leaderboard_position" do
      let(:player_a) { stub(:uuid => 'a') }
      let(:player_b) { stub(:uuid => 'b') }
      
      it "when none of the players have any points, it sorts by the order they were added" do
        scoreboard.new_player player_a
        scoreboard.new_player player_b
        scoreboard.leaderboard_position(player_a).should == 1
        scoreboard.leaderboard_position(player_b).should == 2
      end
    
      it "it sorts by the number of points" do
      end
    end

    it "credits question's points when answer is correct" do
      scoreboard.score(StubAnswer.new("correct"), nil).should == 12
    end

    it "scores flat penalty when server responded with error" do
      scoreboard.score(StubAnswer.new("error_response"), nil).should == -50
    end

    it "scores flat penalty when no response from server" do
      scoreboard.score(StubAnswer.new("no_server_response"), nil).should == -20
    end

    describe "lenient scoreboard" do
      let(:scoreboard) { Scoreboard.new(true, nil) }

      it "scores 0 points when no answer provided" do
        scoreboard.score(StubAnswer.new("wrong",""), nil).should == 0
      end

      it "scores penalty inversely proportional to ranking when wrong answer provided" do
        scoreboard.score(StubAnswer.new("wrong","bar"), 1).should == -12
        scoreboard.score(StubAnswer.new("wrong","bar"), 2).should == -6
      end
    end

    describe "strict scoreboard" do
      let(:scoreboard) { Scoreboard.new(false, nil) }

      it "scores penalty inversely proportional to ranking when no answer provided" do
        scoreboard.score(StubAnswer.new("wrong",""), 1).should == -12
      end

      it "scores penalty inversely proportional to ranking when wrong answer provided" do
        scoreboard.score(StubAnswer.new("wrong","bar"), 1).should == -12
        scoreboard.score(StubAnswer.new("wrong","bar"), 2).should == -6
      end
    end

    class StubAnswer
      attr_reader :result, :answer
      
      def initialize(result, answer = "foo")
        @result = result
        @answer = answer
      end
      def was_answered_correctly
        @result == "correct"
      end
      def was_answered_wrongly
        @result == "wrong"
      end
      def points
        12
      end
      def base_points
        12
      end
    end


  end
end
