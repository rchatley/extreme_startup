require_relative 'question_factory'
require 'uri'
require 'bigdecimal'

module ExtremeStartup

  class RateController
    
    MIN_REQUEST_INTERVAL_SECS = BigDecimal.new("1")
    MAX_REQUEST_INTERVAL_SECS = BigDecimal.new("20")
    REQUEST_DELTA_SECS = BigDecimal.new("0.1")
    
    SLASHDOT_THRESHOLD_SCORE = 1000
    
    def initialize
      @delay = BigDecimal.new("5")
    end
    
    def wait_for_next_request(question)
      sleep delay_before_next_request(question)
    end
    
    def delay_before_next_request(question)
      if (question.was_answered_correctly)        
        if (@delay > MIN_REQUEST_INTERVAL_SECS)
          @delay = @delay - REQUEST_DELTA_SECS
        end
      elsif (question.was_answered_wrongly)
        if (@delay < MAX_REQUEST_INTERVAL_SECS)
          @delay = @delay + REQUEST_DELTA_SECS
        end
      else
        #error response
        return BigDecimal.new("20")
      end
      @prev_question = question
      @delay.to_f
    end
    
    def slashdot_probability_percent
      0.1
    end
    
    def update_algorithm_based_on_score(score)
      if (score > SLASHDOT_THRESHOLD_SCORE && rand(10000) < slashdot_probability_percent * 100)
        return SlashdotRateController.new
      end
      self
    end
  end

  class SlashdotRateController < RateController
    
    def initialize
      @delay = BigDecimal.new("0.01")
    end
        
    def delay_before_next_request(question)
      result = @delay.to_f
      @delay = @delay * BigDecimal.new("1.01")
      result
    end
    
    def update_algorithm_based_on_score(score)
      if (@delay > 5)
        return RateController.new
      end
      self
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
        @rate_controller = @rate_controller.update_algorithm_based_on_score(@scoreboard.current_score(@player))
      end
    end

  end
end
