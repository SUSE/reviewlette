require '/home/jschmid/reviewlette/lib/reviewlette/trello_connection'
require '/home/jschmid/reviewlette/lib/reviewlette/github_connection'
require 'yaml'
require 'octokit'
require 'trello'
require 'debugger'

module Reviewlette

  attr_accessor :trello_connection, :github_connection

  class << self
    def spin!
      @trello_connection = Reviewlette::TrelloConnection.new
      @github_connection = Reviewlette::GithubConnection.new
    end

    def main
      Reviewlette.spin!
      if @github_connection.assigned?(@repo)
        puts "found one"
        title = @github_connection.assigned?(@repo).each { |a| @title = a[:title] }
        @trello_connection.find_card( @title )
        debugger
        puts "i did it "
      end
    end
  end
end

Reviewlette.main