require 'rubygems'
require 'sinatra'
require 'httparty'
require 'uuid'
require 'haml'
require_relative 'ip'
require_relative 'lib/extreme_startup/scoreboard'
require_relative 'lib/extreme_startup/player'
require_relative 'lib/extreme_startup/shopper'

configure do
  set :port, 3000
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

  Thread.new { ExtremeStartup::Shopper.new(player, $scoreboard).start }
  
  personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"  
  haml :player_added, :locals => { :url => personal_page }
end
