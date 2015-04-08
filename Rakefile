require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task :default => :spec

desc 'Run console loaded with gem'
task :console do
  require 'irb'
  require 'irb/completion'
  require 'byebug'
  require 'awesome_print'
  $LOAD_PATH.unshift File.join(File.dirname(__FILE__), 'lib')
  require 'reviewlette'
  ARGV.clear
  IRB.start
end
