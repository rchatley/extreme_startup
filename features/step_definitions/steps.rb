require 'thin'
Thin::Logging.silent = true # uncomment this if things are going wrong on the player

module ExtremeStartup
  module TestingApi

    class TestablePlayer
      attr_reader :url, :name

      def initialize(name, content)
        @name, @content = name, content
        @port = next_free_port
        @app = Class.new(Sinatra::Base) do
          eval content

          get('/ping') { 'OK' }
        end
      end

      def start
        app = @app
        port = @port
        @thread = Thread.new do
          Thin::Server.start('localhost', port) do
            map('/') { run app.new }
          end
        end
        @url = "http://localhost:#{port}"
        Timeout.timeout(2) do
          until responsive?;end
        end
      end

    private

      def responsive?
        response = Net::HTTP.start('localhost', @port) { |http| http.get('/ping') }
        response.body == 'OK'
      rescue Errno::ECONNREFUSED, Errno::EBADF
        false
      end

      def next_free_port
        server = TCPServer.new('127.0.0.1', 0)
        server.addr[1]
      ensure
        server.close if server
      end
    end

    attr_reader :players

    def create_player(name, content)
      @players ||= []
      @players << TestablePlayer.new(name, content)
    end

    def enter_player(player)
      post '/players', :name => player.name, :url => player.url 
    end

    def stub_correct_answer_to_be(correct_answer)
      ::ExtremeStartup::AdditionQuestion.class_eval do
        define_method(:answered_correctly?) do |actual_answer|
          actual_answer.to_s == correct_answer
        end
      end
    end

    def score_for(player_name)
      visit '/'
      find('.player .name', :text => player_name).find(:xpath, '..').find('.score').text.to_i
    end
  end
end

World(ExtremeStartup::TestingApi)

Given /^a player "([^"]*)" who plays like this:$/ do |player_name, content|
  create_player player_name, content
end

Given /^the correct answer to every question is '(\d+)'$/ do |answer|
  stub_correct_answer_to_be answer
end

When /^the two players are entered$/ do
  players.each do |player|
    player.start
    enter_player player
  end
end

When /^the game is played for (\d+) second$/ do |num_seconds|
  sleep num_seconds.to_i
end

Then /^the scores should be:$/ do |table|
  table.hashes.each do |row|
    score_for(row['player']).should == row['score'].to_i
  end
end
