require_relative 'question_factory'
require 'uri'

module ExtremeStartup
  class WarmupQuizMaster
    class WarmupQuestion < Question
      def initialize(player)
        @player = player
      end

      def correct_answer
        @player.name
      end

      def as_text
        "what is your name"
      end
    end
    
    def initialize(player, scoreboard, question_factory)
      @player = player
      @scoreboard = scoreboard
    end
    
    def start
      got_the_hang_of_it = false

      while true
        question = WarmupQuestion.new(@player)
        url = @player.url + '?q=' + URI.escape(question.to_s)
        puts "GET:" + url

        begin
          question.ask(@player)

          if (question.answered_correctly?(question.answer)) then
            puts "player #{@player.name} was correct"

            if !got_the_hang_of_it
              @scoreboard.increment_score_for(@player, question)
              got_the_hang_of_it = true
            end
          else
            puts "player #{@player.name} was wrong"
          end
        rescue => exception
          puts "player #{@player.name} was down - try again later #{exception}, #{exception.backtrace}"
        end
        sleep 5
      end
    end
  end

  class QuizMaster
    def initialize(player, scoreboard, question_factory)
      @player = player
      @scoreboard = scoreboard
      @question_factory = question_factory
    end
    
    def player_passed?(response)
      response.to_s.downcase.strip == "pass"
    end
  
    def start
      while true
        question = @question_factory.next_question(@player)
        question.ask(@player)
        puts "For player #{@player}\n#{question.display_result}"
        @scoreboard.increment_score_for(@player, question)
        sleep question.delay_before_next
      end
    end
    
   
  end
end
