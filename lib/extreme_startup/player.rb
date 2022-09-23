require 'uuid'

module ExtremeStartup
  
  class LogLine
    attr_reader :id, :result, :points
    def initialize(id, result, points)
      @id = id
      @result = result
      @points = points
    end
    
    def to_s
      "#{@id}: #{@result} - points awarded: #{@points}"
    end
  end
  
  class Player
    attr_reader :name, :url, :uuid, :log

    class << self
      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s[0..7]
      end
    end

    def initialize(params = {})  
      @name = params['name']
      @url = sanitise(params['url'])
      @uuid = Player.generate_uuid
      @log = []
    end

    def sanitise(given_url)
      url = given_url

      if url.end_with? "/"
        url = url.chop
      end

      url = (url.end_with? "/api") ? url : url + "/api"
      url.gsub("https://", "http://")
    end

    def log_result(id, msg, points)
      @log.unshift(LogLine.new(id, msg, points))
    end

    def to_s
      "#{name} (#{url})"
    end
  end
end