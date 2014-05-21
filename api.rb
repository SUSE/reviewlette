require 'httparty'
require 'json'
require 'highline/import'
require 'debugger'
module Api
  class GitHub
    include HTTParty
    base_uri 'api.github.com'
    puts "user: "
    user = gets.chomp

#    debugger
    headers {"User-Agent" "#{user}"
             "Password" "#{password}"
            }
    basic_auth "#{user}", "#{password}"
end
end

