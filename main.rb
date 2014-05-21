require 'httparty'
require 'json'

token = 'bea3c333a33f0e557d8d84b125eddea8f92cce57'

user = HTTParty.get 'https://api.github.com/user',
                    headers: {
                        'Authorization' => "token #{token}",
                        'User-Agent' => 'jschmid1'
                    }


puts "#{user["login"]}"


members = HTTParty.get 'https://api.github.com/users',
                    headers: {
                        'Authorization' => "token #{token}",
                        'User-Agent' => 'jschmid1'
                    }
