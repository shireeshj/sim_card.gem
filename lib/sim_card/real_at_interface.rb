class SimCard
  
  class RealAtInterface < AtInterface
    def send command
      puts "SIM CMD IN:#{command.inspect}" if @debug_mode
      @serial_port.write(command + "\r")
      
      buffer = ''
      while IO.select([@serial_port], [], [], 0.25)
        chr = @serial_port.getc.chr;
        buffer += chr
      end
      puts "SIM RESPONSE OUT:#{buffer.inspect}" if @debug_mode
      buffer
    end
  end
 
end