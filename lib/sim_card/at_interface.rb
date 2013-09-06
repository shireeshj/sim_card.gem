class SimCard
  
  class AtInterface
    def initialize serial_port, debug_mode = false
      @serial_port = serial_port
      @debug_mode = debug_mode
    end
  
    def send command
      raise Error.new('implement me via subclass')
    end
  end
  
end