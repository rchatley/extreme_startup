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
      @url = params['url']
      @uuid = Player.generate_uuid
      @log = []
    end

    def log_result(id, msg, points)
      @log.unshift(LogLine.new(id, msg, points))
    end

    def to_s
      "#{name} (#{url})"
    end
  end
end