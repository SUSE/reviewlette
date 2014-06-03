require 'yaml'
require 'octokit'
require 'trello'

require 'reviewlette/trello_connection'
#require 'reviewlette/github_connection'

module Reviewlette

  class << self

    def spin!
      @trello_connection = Reviewlette::TrelloConnection.new
      @trello_connection.board.cards.find(123)
    end

  end

end


