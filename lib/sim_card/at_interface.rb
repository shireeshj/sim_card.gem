class SimCard
  
  # Interface for sending AT commands to the SIM card. RealAtInterface class is employed in the Sim class for real communication with the SIM.
  # This class cannot be used directly, as the send method is intended to be abstract and implemented via subclass.
  # The reason why RealAtInterface and AtInterface are separated is to allow mocking in tests.
  class AtInterface
    def initialize serial_port, debug_mode = false
      @serial_port = serial_port
      @debug_mode = debug_mode
    end
  
    # send AT command and receive response
    def send command
      raise Error.new('implement me via subclass')
    end
  end
  
end