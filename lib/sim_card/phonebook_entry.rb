class SimCard
  class PhonebookEntry
    attr_reader :phone_number, :name, :index
    
    def initialize index, phone_number, name
      @phone_number = phone_number
      @name = name
      @index = index
    end
    
  end
end