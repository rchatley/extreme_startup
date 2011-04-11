require_relative 'question_factory'

module ExtremeStartup
  class Shopper
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
            @scoreboard.increment_score_for(@player)
            sleep 5
          else
            puts "player #{@player.name} was wrong"
            sleep 10
          end
        rescue => exception
          puts "player #{@player.name} was down - try again later #{exception}"
          sleep 20
        end
      end
    end
  end
end