Gem::Specification.new do |s|
  s.name        = 'novaposhta'
  s.version     = '0.0.0'
  s.date        = '2013-02-17'
  s.summary     = "Nobvaposhta API"
  s.description = ""
  s.authors     = ["Azamat Khudaygulov"]
  s.email       = 'azamat@hudaygulov.ru'
  s.files       = Dir['lib/**/*.rb']
  s.homepage    = 'https://github.com/azomazo/novaposhta'

  s.add_dependency("nokogiri", "~> 1.5.6")

  s.add_development_dependency "rspec", "~> 2.11.0"
end