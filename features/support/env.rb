$: << File.expand_path(File.dirname(__FILE__) + '/../../lib')
require 'extreme_startup/web_server'

require 'rack/test'
require 'capybara/cucumber'
Capybara.app = ExtremeStartup::WebServer

module RackTestWorld
  include Rack::Test::Methods

  def app
    ExtremeStartup::WebServer
  end
end
World(RackTestWorld)

$silence_logging = true

Before do
  app.players = Hash.new
  app.players_threads = Hash.new
  app.scoreboard = ExtremeStartup::Scoreboard.new(false)
end

After do
  app.players_threads.each do |uuid, thread|
    thread.exit
  end
  app.question_factory = ExtremeStartup::QuestionFactory.new
end
