class SimCard
  class Phonebook
    attr_reader :min_index, :max_index, :entries
    
    def initialize at_interface
      @at_interface = at_interface
      @entries = nil
      
      switch_to_sim_phonebook
      load_basic_info
    end
    
    def all_entries
      return @entries if @entries
      
      @entries = []
      (@min_index..@max_index).to_a.each do |index|
        raw = @at_interface.send "AT+CPBR=#{index}"
        next if raw.include?("ERROR") # blank entry
        
        _, phone_number, _, name, _ = raw.split("\"")
        @entries << PhonebookEntry.new(index, phone_number, name)
      end
      
      return @entries
    end
    
    def fuzzy_search_by_number phone_number, tail_length = 8

      query_phone_number = phone_number[(-1 * tail_length)..-1]
      all_entries.each do |entry|
        entry_phone_number = entry.phone_number[(-1 * tail_length)..-1]
        if query_phone_number == entry_phone_number
          return entry
        end
      end
      
      return nil
    end
    
    private
    
    def switch_to_sim_phonebook
      response = @at_interface.send "AT+CPBS=\"SM\""
      raise Error.new("Phonebook: unable to switch to SIM phonebook") unless response.include?('OK')
    end
    
    def load_basic_info
      response = @at_interface.send "AT+CPBR=?"
      match_data = response.match /\((\d+)\-(\d+)\)/
      if match_data.size != 3
        raise Error.new("Phonebook: unable to load basic info from #{response.inspect}")
      end
      
      @min_index = match_data[1].to_i
      @max_index = match_data[2].to_i
    end
    
  end
end