require 'sinatra/base'
require 'httparty'
require 'uuid'
require 'haml'
require 'socket'
require 'json'
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
    set :players_threads, Hash.new
    set :scoreboard, Scoreboard.new
    set :question_factory, QuestionFactory.new
   # set :quizmaster_type, WarmupQuizMaster
    set :quizmaster_type, QuizMaster
    
    get '/' do 
      haml :leaderboard, :locals => { 
          :leaderboard => LeaderBoard.new(scoreboard, players), 
          :players => players  }
    end
    
    get '/scores' do 
      LeaderBoard.new(scoreboard, players).to_json
    end
    
    class LeaderBoard
      def initialize(scoreboard, players)
        @entries = []
        scoreboard.leaderboard.each do |entry| 
          @entries << LeaderBoardEntry.new(entry[0], players[entry[0]], entry[1])
        end
      end
      
      def each(&block)
        @entries.each &block
      end
      
      def to_json(*a)
        @entries.to_json(*a)
      end
    end
    
    class LeaderBoardEntry
      attr_reader :playerid, :playername, :score
      def initialize(id, name, score)
        @playerid = id;
        @playername = name;
        @score=score;
      end
      
      def to_json(*a)
        {
          'playerid'   => playerid,
          'playername' => playername,
          'score' => score
        }.to_json(*a)
      end
    end

    get '/graph' do 
      haml :scores
    end
    
    get %r{/players/([\w]+)} do |uuid|
      haml :personal_page, :locals => { :name => players[uuid].name, :playerid => uuid, :score => scoreboard.scores[uuid], :log => players[uuid].log[0..25] }
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
    
    get %r{/withdraw/([\w]+)} do |uuid|
      scoreboard.delete_player(players[uuid])
      players.delete(uuid)
      players_threads[uuid].kill
      players_threads.delete(uuid)
      redirect '/'
    end
    
    post '/players' do
      player = Player.new(params)
      scoreboard.new_player(player)
      players[player.uuid] = player
      
      player_thread = Thread.new do
        settings.quizmaster_type.new(player, scoreboard, question_factory).start
      end
      players_threads[player.uuid] = player_thread
  
      personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"
      haml :player_added, :locals => { :url => personal_page }
    end
    
  private
    
    def local_ip
      UDPSocket.open {|s| s.connect("64.233.187.99", 1); s.addr.last}
    end
    
    [:players, :players_threads, :scoreboard, :question_factory].each do |setting|
      define_method(setting) do
        settings.send(setting)
      end
    end
    
  end
end
