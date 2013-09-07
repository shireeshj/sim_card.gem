class SimCard
  class PhonebookEntry
    attr_reader :phone_number, :name, :index
    
    # single entry in phonebook
    # * index - position on SIM 
    # * phone_number
    # * name 
    def initialize index, phone_number, name
      @phone_number = phone_number
      @name = name
      @index = index
    end
    
  end
end