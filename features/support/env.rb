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
end

After do
  app.players_threads.each do |uuid, thread|
    thread.exit
  end
  app.players.clear
  app.players_threads.clear
  app.scoreboard = ExtremeStartup::Scoreboard.new(false, ExtremeStartup::Events.new($stdout))
  app.question_factory = ExtremeStartup::QuestionFactory.new
end
