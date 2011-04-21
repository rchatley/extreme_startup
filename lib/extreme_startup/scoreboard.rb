module ExtremeStartup
  class Scoreboard
    attr_reader :scores
  
    def initialize
      @scores = Hash.new { 0 }
    end
  
    def increment_score_for(player, increment)
      @scores[player.uuid] += increment
    end
  
    def new_player(player)
      @scores[player.uuid] = 0
    end
  
    def leaderboard
      @scores.sort{|a,b| a[1]<=>b[1]}.reverse
    end
  end
end
