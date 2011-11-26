require_relative 'question_factory'
require 'uri'
require 'bigdecimal'

module ExtremeStartup

  class RateController
    
    def initialize
      @delay = BigDecimal.new("5")
    end
    
    def wait_for_next_request(question)
      sleep delay_before_next_request(question)
    end
    
    def delay_before_next_request(question)
      if (question.was_answered_correctly)        
        if (@delay > 1)
          @delay = @delay - BigDecimal.new("0.1")
        end
      elsif (question.was_answered_wrongly)
        if (@delay < 20)
          @delay = @delay + BigDecimal.new("0.1")
        end
      else
        #error response
        return BigDecimal.new("20")
      end
      @prev_question = question
      @delay.to_f
    end
  end

  class QuizMaster
    def initialize(player, scoreboard, question_factory)
      @player = player
      @scoreboard = scoreboard
      @question_factory = question_factory
      @rate_controller = RateController.new
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
        @rate_controller.wait_for_next_request(question)
      end
    end

  end
end
