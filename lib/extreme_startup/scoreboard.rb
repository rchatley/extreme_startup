module ExtremeStartup
  class Scoreboard
    attr_reader :scores
  
    def initialize(lenient)
      @lenient = lenient
      @scores = Hash.new { 0 }
      @correct_tally = Hash.new { 0 }
      @incorrect_tally = Hash.new { 0 }
      @request_counts = Hash.new { 0 }
    end
  
    def increment_score_for(player, question)
      increment = score(question, leaderboard_position(player))
      @scores[player.uuid] += increment
      if (increment > 0)
        @correct_tally[player.uuid] += 1
      elsif (increment < 0)
        @incorrect_tally[player.uuid] += 1
      end
      puts "added #{increment} to player #{player.name}'s score. It is now #{@scores[player.uuid]}"
      player.log_result(question.id, question.result, increment)
    end
    
    def record_request_for(player)
      @request_counts[player.uuid] += 1
    end
  
    def new_player(player)
      @scores[player.uuid] = 0
    end
    
    def delete_player(player)
      @scores.delete(player.uuid)
    end
    
    def current_score(player)
      @scores[player.uuid]
    end
    
    def current_total_correct(player)
      @correct_tally[player.uuid]
    end
    
    def current_total_not_correct(player)
       @incorrect_tally[player.uuid]
    end
  
    def total_requests_for(player)
       @request_counts[player.uuid]
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
        when "wrong"          then @lenient ? allow_passes(question, leaderboard_position) : penalty(question, leaderboard_position)
        when "error_response" then -50
        when "no_server_response"     then -20
        else puts "!!!!! unrecognized result '#{question.result}' from #{question.inspect} in Scoreboard#score"
      end
    end
    
    def allow_passes(question, leaderboard_position)
      (question.answer == "") ? 0 : penalty(question, leaderboard_position)
    end
    
    def penalty(question, leaderboard_position)
      -1 * question.points / leaderboard_position
    end
     
  end
end
