require 'octokit'
require 'highline/import'


module Auth
  class Basic
    def basic_auth
      client = Octokit::Client.new \
      :login => 'jschmid1',
      :password => ask("Enter password: ") { |q| q.echo = false }
    end
  end
end












############ OPTIONAL AUTH ###############


#client.create_authorization(:scopes => ["user"], :note => "Name of token")
#client = Octokit::Client.new \
#    :client_id     => "24f4471999a562f33e5c",
#    :client_secret => "5f5a34f69ec94f34c28fe1ec33303851329dc4c6"

#user = Octokit.user 'jschmid1'

## or better use the token?

#client = Octokit::Client.new(:access_token=>"f4dc4255b28faf21e80d81ea07748fccff25e147")

