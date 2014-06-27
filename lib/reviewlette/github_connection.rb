require 'debugger'
require 'yaml'
require 'octokit'

module Reviewlette

  class GithubConnection

    GITHUB_CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/.github.yml")

    attr_accessor :client, :repo

    def initialize
      gh_connection
    end

    def gh_connection
      @repo = GITHUB_CONFIG['repo']
      @client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
    end

    def pull_merged?(repo, number)
      client.pull_merged?(repo, number)
    end

    def add_assignee(number, title, body, name)
      @client.update_issue(@repo, number, title, body, :assignee => name)
    end

    def comment_on_issue(number, name, trello_card_url)
      @client.add_comment(@repo, number, "@#{name} is your reviewer :thumbsup: check #{trello_card_url}")
    end

    def list_issues(repo)
      @client.list_issues(repo)
    end

    def team
      @team ||= NAMES.values
    end
  end
end
