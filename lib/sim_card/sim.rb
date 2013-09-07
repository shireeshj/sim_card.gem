class SimCard
  
  # the initial idea is borrowed from here:
  # http://www.dzone.com/snippets/send-and-receive-sms-text

  class Sim
  
    # connect to SIM card. user_options may contain:
    # * port : device where the gsm modem is connected, default is '/dev/ttyUSB0'
    # * speed : connection speed in bauds, default is 9600
    # * pin : pin code to your sim card. not required if your sim does not require authorization via pin
    # * sms_center_no : SMS center of you provider. required only if you want to send SMS messages
    # * debug_mode: when set to true, will print all communication with SIM card to stdout
    def initialize(user_options = {})
      default_options = {:port => '/dev/ttyUSB0', :speed => 9600}
      options = default_options.merge user_options
      
      @port = SerialPort.new options[:port], options[:speed]
      
      debug_mode = (options[:debug_mode] == true)
      @at_interface = RealAtInterface.new @port, debug_mode
      
      initial_check
      authorize options[:pin]
      # Set to text mode
      @at_interface.send "AT+CMGF=1"
      # Set SMSC number
      @at_interface.send "AT+CSCA=\"#{options[:sms_center_no]}\"" if options[:sms_center_no]
    end
  
    # correctly disconnect from SIM card
    def close
      @port.close
    end

    # send SMS message
    def send_sms number, message_text
      @at_interface.send "AT+CMGS=\"#{number}\""
      @at_interface.send "#{message_text[0..140]}#{26.chr}\r\r"
      sleep 3
      @at_interface.send "AT"
    end
  
    # list SMS messages in SIM memory
    def sms_messages
      ReceivedSmsMessage.load_messages @at_interface
    end
    
    # return instance of Phonebook
    def phonebook
      Phonebook.new @at_interface
    end
    
    # remove SMS message from SIM card memory
    # * sms_message: instance of SimCard::SmsMessage to be deleted
    def delete_sms_message sms_message
      @at_interface.send "AT+CMGD=#{sms_message.message_id}"
    end
    
    # signal strengh in dBm. -60 is almost perfect signal, -112 is very poor (call dropping bad)
    def signal_strength
      sq = SimCard::SignalQuality.new @at_interface
      return sq.signal_strength
    end
    
    # for hackers
    def send_raw_at_command cmd
      @at_interface.send cmd
    end
    
    private
    
    def initial_check
      response = @at_interface.send "AT"
      if response.include?("OK")
        return true
      else
        raise Error.new("SIM is not responsing properly to initial handshake. response: #{response.inspect}")
      end
    end
    
    def authorize pin
      auth_status = @at_interface.send "AT+CPIN?"
      if auth_status.include?('READY')
        # no pin required or already authorized
        return true
      elsif auth_status.include?('SIM PIN')
        response = @at_interface.send "AT+CPIN=\"#{pin}\""
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