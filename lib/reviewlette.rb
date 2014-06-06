require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'
require 'yaml'
require 'octokit'
require 'trello'
require 'debugger'

module Reviewlette

  class << self
    def spin!
      debugger
      @trello_connection = Reviewlette::TrelloConnection.new
      @github_connection = Reviewlette::GithubConnection.new
    end
  end
end

Reviewlette.spin!


