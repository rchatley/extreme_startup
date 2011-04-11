require 'rubygems'
require 'sinatra'
require 'httparty'
require 'uuid'
require 'haml'
require_relative 'ip'
require_relative 'lib/extreme_startup/question_factory'
require_relative 'lib/extreme_startup/scoreboard'
require_relative 'lib/extreme_startup/player'

configure do
  set :port, 3000
end

class Shopper
  def initialize(player, scoreboard)
    @player = player
    @scoreboard = scoreboard
    @question_factory = ExtremeStartup::QuestionFactory.new
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
        if (question.answered_correctly(response)) then
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

$players = Hash.new
$scoreboard = ExtremeStartup::Scoreboard.new

get '/' do 
  haml :leaderboard, :locals => { :leaderboard => $scoreboard.leaderboard, :players => $players  }
end

get %r{/players/([\w]+)} do |uuid|
  haml :personal_page, :locals => { :name => $players[uuid].name, :score => $scoreboard.scores[uuid] }
end

get '/players' do
  haml :add_player
end

Thread.abort_on_exception = true

post '/players' do
  player = ExtremeStartup::Player.new(params)
  $scoreboard.new_player(player)
  $players[player.uuid] = player

  Thread.new { Shopper.new(player, $scoreboard).start }
  
  personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"  
  haml :player_added, :locals => { :url => personal_page }
end
