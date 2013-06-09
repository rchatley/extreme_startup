require 'uuid'
require 'json'
require 'thread'

# provide timestamp as milliseconds since epoch
class Time
  def to_ms
    (self.to_f * 1000.0).to_i
  end
end

module ExtremeStartup

  # An object exposing all the registrable and replayable events for the game as methods
  #
  # An instance of Events is intended to be used for generating a replayable trace of an ExtremeSTartup session, in
  # order to be able to save, pause and restore a game at a known state.
  class Events

    class << self

      def generate_uuid
        @uuid_generator ||= UUID.new
        @uuid_generator.generate.to_s
      end

      def timestamp
        now = Time.now.to_ms
      end
      
    end

    def initialize(out = nil)
      now = Time.now
      if out.nil? 
        @out = File.new("extreme_startup_%d_%d_%d_%d_%d.log" % [now.year, now.month, now.day, now.hour, now.min] , "w+")
      else 
        @out = out
      end
      @semaphore = Mutex.new
    end
    
    # A player has just registered for the game and has started playing
    #
    # +player+ :: a hash containing a unique id and timestamp for the event, the name, url and pid of the player
    def player_started(player)
      output({
                 :event     => "player_started",
                 :id        => Events.generate_uuid,
                 :timestamp => Events.timestamp,
                 :name      => player.name,
                 :url       => player.url,
                 :pid       => player.uuid
             })
    end

    # A player has just withdrawn from the game
    #
    # +player+ ::  the Player object
    # return a hash containing a unique id and timestamp for the event, the name, url and pid of the player
    def player_withdraw(player)
      output({
                 :event     => "player_withdraw",
                 :id        => Events.generate_uuid,
                 :timestamp => Events.timestamp,
                 :name      => player.name,
                 :url       => player.url,
                 :pid       => player.uuid
             })
    end

    # Round has been advanced
    #
    # +question_factory+ :: Question factory object advancing round
    # return a hash containing a unique id and timestamp for the event, the name, url and pid of the player
    def advance_round(question_factory)
      output({
                 :event     => "advance_round",
                 :id        => Events.generate_uuid,
                 :timestamp => Events.timestamp,
                 :round      => question_factory.round
             })
    end

    # A question has been asked and answered, possibly with an error
    #
    # +question+ :: Question asked
    def question(player, question) 
      output({
                 :event     => "question",
                 :id        => Events.generate_uuid,
                 :timestamp => Events.timestamp,
                 :playerid  => player.uuid,
                 :question  => question.to_s,
                 :answer    => question.answer,
                 :result    => question.result,
                 :duration  => question.duration
             })
    end
    
    def increment_score(player, increment, new_score)
      output({
                 :event     => "score",
                 :id        => Events.generate_uuid,
                 :timestamp => Events.timestamp,
                 :playerid  => player.uuid,
                 :increment => increment,
                 :score     => new_score
             })      
    end
    
    private
    
    def output(event)
      @semaphore.synchronize {
        @out.print("%s\n" % JSON.generate(event))
        @out.fsync
      }
    end
  end

end