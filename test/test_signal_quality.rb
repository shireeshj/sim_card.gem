require 'test/unit'
require File.join(File.dirname(__FILE__), '..', 'lib', 'sim_card.rb')
 
class TestSignalQuality < Test::Unit::TestCase
  
  class MockAtInterface < SimCard::AtInterface
    def send cmd
      "AT+CSQ\r\r\n+CSQ: 19,99\r\n\r\nOK\r\n"
    end
  end
  
  def test_signal_quality_should_provide_signal_strength_and_bit_error_rate
    sq = SimCard::SignalQuality.new MockAtInterface.new(nil)
    assert_equal -75, sq.signal_strength
  end
end