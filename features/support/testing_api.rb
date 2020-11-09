require 'thin'
Thin::Logging.silent = true # uncomment this if things are going wrong on the player

module TestingApi

  class TestablePlayer
    attr_reader :url, :name
    attr_accessor :personal_page

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
    rescue Errno::ECONNREFUSED, Errno::EBADF, Errno::EADDRNOTAVAIL
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
    player = TestablePlayer.new(name, content)
    @players << player
    player
  end

  def enter_player(player)
    post '/players', :name => player.name, :url => player.url 
    doc = Nokogiri.parse(last_response.body)
    personal_page_link = doc.css('a').first
    player.personal_page = personal_page_link['href']
  end

  def stub_correct_answer_to_be(correct_answer, points_awarded = 1)
    ::ExtremeStartup::AdditionQuestion.class_eval do
      define_method(:answered_correctly?) do |actual_answer|
        actual_answer.to_s == correct_answer
      end
    end
    
    ::ExtremeStartup::AdditionQuestion.class_eval do
      define_method(:points) do 
        points_awarded
      end
    end
    
    ::ExtremeStartup::MaximumQuestion.class_eval do
      define_method(:answered_correctly?) do |actual_answer|
        actual_answer.to_s == correct_answer
      end
    end

    ::ExtremeStartup::MaximumQuestion.class_eval do
      define_method(:points) do
        points_awarded
      end
    end
  end

  def score_for(player_name)
    visit '/'
    find('.player .name', :text => player_name).find(:xpath, '..').find('.points').text.to_i
  end
end

World(TestingApi)

