require_relative 'question_factory'

module ExtremeStartup
  class QuizMaster
    def initialize(player, scoreboard, question_factory)
      @player = player
      @scoreboard = scoreboard
      @question_factory = question_factory
    end
  
    def start
      while true
        question = @question_factory.next_question
        url = @player.url + '?q=' + question.to_s.gsub(' ', '%20')
        puts "GET:" + url
        begin
          response = HTTParty.get(url)
          puts "question was " + question.to_s
          puts "player #{@player.name} said #{response}"
          if (question.answered_correctly?(response)) then
            puts "player #{@player.name} was correct"
            @scoreboard.increment_score_for(@player, question.points)
            @player.log_result(question.id, "correct", question.points)
            sleep 5
          else
            puts "player #{@player.name} was wrong"
            @player.log_result(question.id, "wrong", 0)
            sleep 10
          end
        rescue => exception
          puts "player #{@player.name} was down - try again later #{exception}"
          penalty = -5
          @scoreboard.increment_score_for(@player, penalty)
          @player.log_result(question.id, "no_response", penalty)
          sleep 20
        end
      end
    end
  end
end