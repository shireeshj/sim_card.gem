class SimCard
  
# code below is based on:
# http://www.dzone.com/snippets/send-and-receive-sms-text

  class Sim
  
    # connect to SIM card. user_options may contain:
    # * port : device where the gsm modem is connected, default is '/dev/ttyUSB0'
    # * speed : connection speed in bauds, default is 9600
    # * pin : pin to your sim card, default is '0000'
    # * sms_center_no : SMS center of you provider. required only if you want to send SMS messages
    def initialize(user_options = {})
      default_options = {:port => '/dev/ttyUSB0', :speed => 9600, :pin => '0000'}
      options = default_options.merge user_options
      
      @port = SerialPort.new(options[:port], options[:speed])
      cmd("AT")
      cmd("AT+CPIN=\"#{options[:pin]}\"")
      # Set to text mode
      cmd("AT+CMGF=1")
      # Set SMSC number
      cmd("AT+CSCA=\"#{options[:sms_center_no]}\"") if options[:sms_center_no]
    end
  
    # correctly disconnect from SIM card
    def close
      @port.close
    end

    def send_sms number, message_text
      cmd("AT+CMGS=\"#{number}\"")
      cmd("#{message_text[0..140]}#{26.chr}\r\r")
      sleep 3
      wait
      cmd("AT")
    end
  
    # list SMS messages in SIM memory
    def sms_messages
      raw_sim_output = cmd("AT+CMGL=\"ALL\"")
      SmsMessage.to_messages raw_sim_output
    end
    
    # remove SMS message from SIM card memory
    # * sms_message: instance of SimCard::SmsMessage to be deleted
    def delete_sms_message sms_message
      cmd("AT+CMGD=#{sms_message.message_id}")
    end
  
    private
    def cmd(cmd)
      # puts "SIM CMD IN:#{cmd}"
      @port.write(cmd + "\r")
      wait
    end
    
    def wait
      buffer = ''
      while IO.select([@port], [], [], 0.25)
        chr = @port.getc.chr;
        buffer += chr
      end
      # puts "SIM OUT:#{buffer}"
      buffer
    end
  end
end