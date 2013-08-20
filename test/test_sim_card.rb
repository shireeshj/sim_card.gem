require 'test/unit'
require 'sim_card'
 
class SimCardTest < Test::Unit::TestCase
  
  def test_to_messages_from_raw_input_should_parse_newlines_in_message_text
    raw_sim_output = <<STRING
AT+CMGL="ALL"
+CMGL: 2,"REC READ","+421918987987","","13/08/20,19:00:44+08"
line1
line2

line3

+CMGL: 1,"REC READ","+421918123123","","13/08/20,19:00:24+08"
test1
STRING
    
    messages = SimCard::ReceivedSmsMessage.to_messages raw_sim_output
    assert_equal 2, messages.size
    m1, m2 = messages
    
    assert_equal 'test1', m1.text
    assert_equal '+421918123123', m1.sender_number
    assert_equal '1', m1.message_id
    
    
    assert_equal '+421918987987', m2.sender_number
    assert_equal '2', m2.message_id    
    assert_equal "line1\nline2\n\nline3", m2.text
  end
  
  def test_to_messages_from_raw_input_should_provide_empty_array_when_no_messages_are_present
    raw_sim_output = <<STRING
AT+CMGL="ALL"    
STRING
    
    messages = SimCard::ReceivedSmsMessage.to_messages raw_sim_output
    assert_equal 0, messages.size   
  end
end