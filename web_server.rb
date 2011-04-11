require 'rubygems'
require 'sinatra/base'
require 'httparty'
require 'uuid'
require 'haml'
require_relative 'ip'
require_relative 'lib/extreme_startup/scoreboard'
require_relative 'lib/extreme_startup/player'
require_relative 'lib/extreme_startup/shopper'

Thread.abort_on_exception = true



module ExtremeStartup
  class WebServer < Sinatra::Base

    set :port, 3000
    set :players,    Hash.new
    set :scoreboard, Scoreboard.new
    
    def players
      settings.players
    end

    def scoreboard
      settings.scoreboard
    end

    get '/' do 
      haml :leaderboard, :locals => { 
          :leaderboard => scoreboard.leaderboard, 
          :players => players  }
    end

    get %r{/players/([\w]+)} do |uuid|
      haml :personal_page, :locals => { :name => players[uuid].name, :score => scoreboard.scores[uuid] }
    end

    get '/players' do
      haml :add_player
    end

    post '/players' do
      player = Player.new(params)
      scoreboard.new_player(player)
      players[player.uuid] = player

      Thread.new { Shopper.new(player, scoreboard).start }
  
      personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"
      haml :player_added, :locals => { :url => personal_page }
    end
  end
end

ExtremeStartup::WebServer.run!
