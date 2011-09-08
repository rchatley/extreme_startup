require 'spec_helper'
require 'extreme_startup/scoreboard'

module ExtremeStartup
  describe Scoreboard do
    let(:scoreboard) { Scoreboard.new }
    
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
  end
end