require 'debugger'
require 'yaml'
require 'octokit'

module Reviewlette
  class GithubConnection
    GITHUB_CONFIG = YAML.load_file('/home/jschmid/reviewlette/config/.github.yml')
    attr_accessor :client, :repo

    def initialize
      gh_connection
    end

    # def trello_connection
    #   @trello_connection ||= Reviewlette::TrelloConnection.new
    # end

    def gh_connection
      @repo = 'jschmid1/reviewlette'
      @client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
    end

    def pull_merged?(repo, number)
      client.pull_merged?(repo, number)
    end

    def add_assignee(number, title, body, name)
      @client.update_issue(@repo, number, title, body, :assignee => name)
    end

    def comment_on_issue(repo, number, name)
      @client.add_comment(repo, number, "#{name} is your reviewer :thumbsup:")
    end

    def list_issues(repo)
      @client.list_issues(repo)
    end


  end
end
