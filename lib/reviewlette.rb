require 'yaml'
require 'octokit'
require 'trello'

require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'

module Reviewlette

  class << self

    def spin!
      @trello_connection = Reviewlette::TrelloConnection.new
      @github_connection = Reviewlette::GithubConnection.new
    end

  end

end


