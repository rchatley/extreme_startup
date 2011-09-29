module ExtremeStartup
  class Scoreboard
    attr_reader :scores
  
    def initialize
      @scores = Hash.new { 0 }
    end
  
    def increment_score_for(player, question)
      increment = score(question, leaderboard_position(player))
      @scores[player.uuid] += increment
      puts "added #{increment} to player #{player.name}'s score. It is now #{@scores[player.uuid]}"
      player.log_result(question.id, question.result, increment)
    end
  
    def new_player(player)
      @scores[player.uuid] = 0
    end
    
    def delete_player(player)
      @scores.delete(player.uuid)
    end
  
    def leaderboard
      @scores.sort{|a,b| b[1]<=>a[1]}
    end
    
    def leaderboard_position(player)
      leaderboard.index do |uuid, score|
        uuid == player.uuid
      end + 1
    end
    
    def score(question, leaderboard_position)
      case question.result
        when "correct"        then question.points
        when "wrong"          then penalty(question.points, leaderboard_position)
        when "error_response" then -5
        when "no_answer"     then -20
        else puts "!!!!! unrecognized result '#{question.result}' from #{question.inspect} in Scoreboard#score"
      end
    end
    
    def penalty(points, leaderboard_position)
      -1 * points / leaderboard_position
    end
     
  end
end
