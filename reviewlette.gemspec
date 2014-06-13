Gem::Specification.new do |s|
  s.name  = 'reviewlette'
  s.version = '0.0.3'
  s.date = '2014-06-14'
  s.summary = 'Review-assistant'
  s.description = 'Randomizes your reviewers'
  s.authors = 'Joshua Schmid'
  s.email = 'jschmid@suse.de'
  s.files = ['lib/reviewlette.rb', 'lib/reviewlette/github_connection.rb', 'lib/reviewlette/trello_connection.rb']
  s.homepage = 'https://rubyges.rog/gems/reviewlette'
  s.executables = ["reviewlette"]
  s.license = 'MIT'
end
