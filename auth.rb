require 'octokit'
require 'highline/import'
require 'oauth'


module Auth
  class Basic
    def basic_auth
      client = Octokit::Client.new \
      :login => 'jschmid1',
      :password => ask("Enter password: ") { |q| q.echo = false }
    end
  end
end





