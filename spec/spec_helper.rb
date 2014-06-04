require 'simplecov'
SimpleCov.minimum_coverage 100
SimpleCov.start do
  add_filter '/spec/'
  add_filter 'vendor' # Don't include vendored stuff
end


require 'webmock/rspec'
require 'rspec'
require 'reviewlette'
require 'support/request_stubbing'
require 'debugger'


