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
          response = HTTParty.get(url)
          
          puts "question was " + question.to_s
          puts "player #{@player.name} said #{response}"
          
          if (question.answered_correctly?(response)) then
            puts "player #{@player.name} was correct"
            
            if !got_the_hang_of_it
              @scoreboard.increment_score_for(@player, question.points)
              @player.log_result(question.id, "correct", question.points)
              got_the_hang_of_it = true
            else
              @player.log_result(question.id, "correct again", 0)
            end
            
          else
            puts "player #{@player.name} was wrong"
            @player.log_result(question.id, "wrong", 0)
          end
        rescue => exception
          puts "player #{@player.name} was down - try again later #{exception}"
          @player.log_result(question.id, "no_response", 0)
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
        question = @question_factory.next_question
        url = @player.url + '?q=' + URI.escape(question.to_s)
        puts "GET:" + url
        begin
          response = HTTParty.get(url)
          puts "question was " + question.to_s
          puts "player #{@player.name} said #{response}"
          if (!response.success?) then
             puts "player #{@player.name} had an error - try again later"
              penalty = -5
              @scoreboard.increment_score_for(@player, penalty)
              @player.log_result(question.id, "error_response", penalty)
              sleep 20
          elsif (player_passed?(response)) then
            puts "player #{@player.name} passed"
            @player.log_result(question.id, "pass", 0)
            sleep 10
          elsif (question.answered_correctly?(response)) then
            puts "player #{@player.name} was correct"
            @scoreboard.increment_score_for(@player, question.points)
            @player.log_result(question.id, "correct", question.points)
            sleep 5
          else
            puts "player #{@player.name} was wrong"
            penalty = -1 * (question.points.to_f / 10)
            @scoreboard.increment_score_for(@player, penalty)
            @player.log_result(question.id, "wrong", penalty)
            sleep 10
          end
        rescue => exception
          puts "player #{@player.name} was down - try again later #{exception}"
          penalty = -2
          @scoreboard.increment_score_for(@player, penalty)
          @player.log_result(question.id, "no_response", penalty)
          sleep 20
        end
      end
    end
  end
end