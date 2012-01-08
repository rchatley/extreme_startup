module ExtremeStartup
  
  class GameState
    def initialize
      @paused = false
    end   
       
    def is_running?
      ! @paused
    end
    
    def pause
      @paused = true
    end
    
    def resume
      @paused = false
    end
  end
  
end