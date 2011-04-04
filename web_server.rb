require 'rubygems'
require 'sinatra'
require 'httparty'

configure do
  set :port, 3000
end

$players = []

class Scoreboard
  attr_reader :scores
  
  def initialize
    @scores = Hash.new { 0 }
  end
  
  def increment_score_for(player_name)
    @scores[player_name] += 1
  end
end

$scoreboard = Scoreboard.new

class Shopper
  def initialize(player, scoreboard)
    @player = player
    @scoreboard = scoreboard
  end
  
  def start
    while true
      response = HTTParty.get(@player.url)
      @scoreboard.increment_score_for(@player.name)
      puts "player #{@player.name} said #{response}"
      sleep 5
    end
  end
end

class Player
  attr_reader :name, :url
  
  def initialize(params)
    @name = params['name']
    @url = params['url']
  end
  
  def to_s
    "#{name} (#{url})"
  end
end

get '/' do 
  $players.map do |player|
    "#{player} : #{$scoreboard.scores[player.name]}"
  end.join("<br/>")
end

get '/players' do
  File.read('players.html')
end

Thread.abort_on_exception = true

post '/players' do
  player = Player.new(params)
  Thread.new { Shopper.new(player, $scoreboard).start }
  $players << player
  'thanks'
end