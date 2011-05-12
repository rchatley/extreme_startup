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