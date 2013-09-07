Gem::Specification.new do |s|
  s.name        = 'sim_card'
  s.author      = 'Peter Vojtek'
  s.version     = '0.1.1'
  s.summary     = "Access and control cellphone SIM card functionality via AT commands"
  s.files       = ["lib/sim_card.rb", "lib/sim_card/sim.rb", "lib/sim_card/received_sms_message.rb", "lib/sim_card/signal_quality.rb"]
  s.license     = 'MIT'
  s.has_rdoc    = true
  s.homepage     = 'https://github.com/petervojtek/sim_card.gem'
end
