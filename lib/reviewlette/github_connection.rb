require 'debugger'
require 'yaml'

module Reviewlette

  class GithubConnection

    TRELLO_CONFIG = ::YAML.load_file('/home/jschmid/reviewlette/config/.github.yml')

    def initialize
      setup_github
    end





    private

    def setup_github
      @repo = 'jschmid1/reviewlette'
      @client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
    end

  end
end
