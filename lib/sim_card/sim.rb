class SimCard
  
  # code below is based on:
  # http://www.dzone.com/snippets/send-and-receive-sms-text

  class Sim
  
    # connect to SIM card. user_options may contain:
    # * port : device where the gsm modem is connected, default is '/dev/ttyUSB0'
    # * speed : connection speed in bauds, default is 9600
    # * pin : pin code to your sim card. not required if your sim does not require authorization via pin
    # * sms_center_no : SMS center of you provider. required only if you want to send SMS messages
    def initialize(user_options = {})
      default_options = {:port => '/dev/ttyUSB0', :speed => 9600}
      options = default_options.merge user_options
      
      @port = SerialPort.new(options[:port], options[:speed])
      initial_check
      authorize options[:pin]
      # Set to text mode
      send_raw_at_command("AT+CMGF=1")
      # Set SMSC number
      send_raw_at_command("AT+CSCA=\"#{options[:sms_center_no]}\"") if options[:sms_center_no]
    end
  
    # correctly disconnect from SIM card
    def close
      @port.close
    end

    def send_sms number, message_text
      send_raw_at_command("AT+CMGS=\"#{number}\"")
      send_raw_at_command("#{message_text[0..140]}#{26.chr}\r\r")
      sleep 3
      wait
      send_raw_at_command("AT")
    end
  
    # list SMS messages in SIM memory
    def sms_messages
      raw_sim_output = send_raw_at_command("AT+CMGL=\"ALL\"")
      ReceivedSmsMessage.to_messages raw_sim_output
    end
    
    # remove SMS message from SIM card memory
    # * sms_message: instance of SimCard::SmsMessage to be deleted
    def delete_sms_message sms_message
      send_raw_at_command("AT+CMGD=#{sms_message.message_id}")
    end
    
    # in dBm. -60 is almost perfect signal, -112 is very poor (call dropping bad)
    def signal_strength
      raw_sim_output = send_raw_at_command 'AT+CSQ'
      sq = SimCard::SignalQuality.new raw_sim_output
      return sq.signal_strength
    end

    # directly send AT commands to SIM
    def send_raw_at_command cmd
      # puts "SIM CMD IN:#{cmd}"
      @port.write(cmd + "\r")
      wait
    end
    
    private
    def wait
      buffer = ''
      while IO.select([@port], [], [], 0.25)
        chr = @port.getc.chr;
        buffer += chr
      end
      # puts "SIM OUT:#{buffer}"
      buffer
    end
    
    def initial_check
      response = send_raw_at_command("AT")
      if response.include?("OK")
        return true
      else
        raise Error.new("SIM is not responsing properly to initial handshake. response: #{response.inspect}")
      end
    end
    
    def authorize pin
      auth_status = send_raw_at_command("AT+CPIN?")
      if auth_status.include?('READY')
        # no pin required or already authorized
        return true
      elsif auth_status.include?('SIM PIN')
        response = send_raw_at_command("AT+CPIN=\"#{pin}\"")
        if response.include?('OK')
          return true
        else
          raise Error.new("SIM authorization failed: #{response.inspect}")
        end
      else
        raise Error.new("unknown SIM authorization status: #{auth_status.inspect}")
      end
    end
  end
end