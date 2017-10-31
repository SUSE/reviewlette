$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
    $:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'coveralls'
Coveralls.wear!

require 'simplecov'
SimpleCov.minimum_coverage 50
SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
SimpleCov.start do
  add_filter '/spec'
end


require 'webmock/rspec'
require 'rspec'
require 'reviewlette'
