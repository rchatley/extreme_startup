module ExtremeStartup
  class Player
    attr_reader :name, :url, :uuid

    class << self
      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s[0..7]
      end
    end

    def initialize(params)
      @name = params['name']
      @url = params['url']
      @uuid = Player.generate_uuid
    end

    def to_s
      "#{name} (#{url})"
    end
  end
end