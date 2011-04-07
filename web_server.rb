require 'rubygems'
require 'sinatra'
require 'httparty'
require 'uuid'
require 'haml'
require_relative 'ip'

configure do
  set :port, 3000
end

class Scoreboard
  attr_reader :scores
  
  def initialize
    @scores = Hash.new { 0 }
  end
  
  def increment_score_for(player)
    @scores[player.uuid] += 1
  end
  
  def new_player(player)
    @scores[player.uuid] = 0
  end
  
  def leaderboard
    @scores.sort{|a,b| a[1]<=>b[1]}.reverse
  end
end

class Question
  def initialize(a,b)
    @n1 = a
    @n2 = b
  end
  
  def answered_correctly(answer) 
    correct_answer = @n1 + @n2
    return correct_answer.to_s.strip == answer.to_s.strip
  end
  
  def to_s
    return "what is #{@n1} plus #{@n2}"
  end
end

class QuestionFactory
  def next_question
    return Question.new(rand(5), rand(5))
  end
end

class Shopper
  def initialize(player, scoreboard)
    @player = player
    @scoreboard = scoreboard
    @question_factory = QuestionFactory.new
  end
  
  def start
    while true
      question = @question_factory.next_question
      url = @player.url + '?q=' + question.to_s.gsub(' ', '%20')
      puts "GET:" + url
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
    end
  end
end

class Player
  attr_reader :name, :url, :uuid
  
  def initialize(params)
    @name = params['name']
    @url = params['url']
    @uuid = $uuid_generator.generate.to_s[0..7]
  end
  
  def to_s
    "#{name} (#{url})"
  end
end

$uuid_generator = UUID.new
$players = Hash.new
$scoreboard = Scoreboard.new

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
  player = Player.new(params)
  $scoreboard.new_player(player)
  $players[player.uuid] = player

  Thread.new { Shopper.new(player, $scoreboard).start }
  
  personal_page = "http://#{local_ip}:#{@env["SERVER_PORT"]}/players/#{player.uuid}"  
  haml :player_added, :locals => { :url => personal_page }
end