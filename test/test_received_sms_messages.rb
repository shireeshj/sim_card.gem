require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sim_card.rb')
 
class TestReceivedSmsMessages < Test::Unit::TestCase
  
  class MockAtInterface1 < SimCard::AtInterface
    def send cmd
      <<STRING
AT+CMGL="ALL"
+CMGL: 2,"REC READ","+421918987987","","13/08/20,19:00:44+08"
line1
line2

line3

+CMGL: 1,"REC READ","+421918123123","","13/08/20,19:00:24+08"
test1
STRING
    end
  end
  
  def test_to_messages_from_raw_input_should_parse_newlines_in_message_text
    messages = SimCard::ReceivedSmsMessage.load_messages MockAtInterface1.new(nil)
    assert_equal 2, messages.size
    m1, m2 = messages
    
    assert_equal 'test1', m1.text
    assert_equal '+421918123123', m1.sender_number
    assert_equal '1', m1.message_id
    
    assert_equal '+421918987987', m2.sender_number
    assert_equal '2', m2.message_id    
    assert_equal "line1\nline2\n\nline3", m2.text
  end
  
  def test_timestamp_is_parsed_properly
    messages = SimCard::ReceivedSmsMessage.load_messages MockAtInterface1.new(nil)
    m1 = messages.first
    t = m1.timestamp
    assert_equal 2013, t.year
    assert_equal 8, t.month
    assert_equal 20, t.day
    assert_equal 19, t.hour
    assert_equal 0, t.minute
    assert_equal 24, t.second
  end
  
  class MockAtInterface2 < SimCard::AtInterface
    def send cmd
      <<STRING
AT+CMGL="ALL"    
STRING
    end
  end  
  
  def test_to_messages_from_raw_input_should_provide_empty_array_when_no_messages_are_present
    messages = SimCard::ReceivedSmsMessage.load_messages MockAtInterface2.new(nil)
    assert_equal 0, messages.size   
  end
  
end