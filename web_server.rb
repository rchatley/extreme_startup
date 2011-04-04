require 'rubygems'
require 'sinatra'
require 'httparty'
require 'uuid'
require 'haml'

configure do
  set :port, 3000
end

$players = []

$uuid = UUID.new

class Scoreboard
  attr_reader :scores
  
  def initialize
    @scores = Hash.new { 0 }
  end
  
  def increment_score_for(player_uuid)
    @scores[player_uuid] += 1
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
      @scoreboard.increment_score_for(@player.uuid)
      puts "player #{@player.name} said #{response}"
      sleep 5
    end
  end
end

class Player
  attr_reader :name, :url, :uuid
  
  def initialize(params)
    @name = params['name']
    @url = params['url']
    @uuid = $uuid.generate.to_s[0..7]
  end
  
  def to_s
    "#{name} (#{url})"
  end
end

get '/' do 
  $players.map do |player|
    "#{player} : #{$scoreboard.scores[player.uuid]}"
  end.join("<br/>")
end

get %r{/players/([\w]+)} do |uuid|
  "Hello, #{uuid}! Your score is #{$scoreboard.scores[uuid]}" 
end

get '/players' do
  haml :add_player
end

Thread.abort_on_exception = true

post '/players' do
  player = Player.new(params)
  Thread.new { Shopper.new(player, $scoreboard).start }
  $players << player
  haml :player_added, :locals => { :url => "http://localhost:3000/players/#{player.uuid}" }
end