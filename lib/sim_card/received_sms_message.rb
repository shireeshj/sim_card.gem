class SimCard
  class ReceivedSmsMessage
    
    # parse raw output from SIM card and return list of ReceivedSmsMessage instances.
    # see SimCardTest for examples of raw SIM output.
    def self.to_messages raw_sim_output
      messages = []
      raw_input2 = raw_sim_output[14..-1] # remove initial AT+CMGL="ALL"\n
      raw_input3 = (raw_input2 || '').split('+CMGL: ')[1..-1]
      
      (raw_input3 || []).each do |raw_message|
        header, *text_lines = raw_message.split("\n")
        
        # +CMGL: 2,"REC READ","+421918987987","","13/08/20,19:00:44+08"
        message_id, _, sender_number, _, date, time = header.gsub("\"", '').split(',')
        
        message_text = text_lines.join "\n"
        
        sms_message = ReceivedSmsMessage.new message_id, sender_number, message_text
        messages << sms_message
      end
      
      return messages.reverse
    end
    
    attr_reader :message_id, :sender_number, :text
    
    # * message_id : ID of the sms message as provided by the SIM card
    # * sender_number : who sent the message
    # * text : message text
    def initialize message_id, sender_number, text
      @message_id = message_id
      @sender_number = sender_number
      @text = text
    end
    
    def to_s
      <<STRING
ID:   #{@message_id}
FROM: #{@sender_number}
TEXT: #{@text}
STRING
    end
    
  end
end