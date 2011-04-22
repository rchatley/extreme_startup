require 'sinatra/base'
require 'httparty'
require 'uuid'
require 'haml'
require "socket"
require_relative 'scoreboard'
require_relative 'player'
require_relative 'quiz_master'

Thread.abort_on_exception = true

module ExtremeStartup
  class WebServer < Sinatra::Base

    set :port, 3000
    set :static, true 
    set :public, 'public'
    set :players,    Hash.new
    set :scoreboard, Scoreboard.new
    set :question_factory, QuestionFactory.new
    
    get '/' do 
      haml :leaderboard, :locals => { 
          :leaderboard => scoreboard.leaderboard, 
          :players => players  }
    end

    get %r{/players/([\w]+)} do |uuid|
      haml :personal_page, :locals => { :name => players[uuid].name, :score => scoreboard.scores[uuid], :log => players[uuid].log }
    end

    get '/players' do
      haml :add_player
    end
    
    get '/advance_round' do
      question_factory.advance_round
      redirect to('/round')
    end

    get '/round' do
      question_factory.round.to_s
    end

    post '/players' do
      player = Player.new(params)
      scoreboard.new_player(player)
      players[player.uuid] = player

      Thread.new { QuizMaster.new(player, scoreboard, question_factory).start }
  
      personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"
      haml :player_added, :locals => { :url => personal_page }
    end
    
  private
    
    def local_ip
      UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
    end
    
    [:players, :scoreboard, :question_factory].each do |setting|
      define_method(setting) do
        settings.send(setting)
      end
    end
    
  end
end
