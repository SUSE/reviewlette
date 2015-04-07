require 'yaml'
require 'octokit'

GITHUB_CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/github.yml")

class GithubConnection

  attr_accessor :client, :repo

  def initialize
    @client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
    @repo = GITHUB_CONFIG['repo']
  end

  def list_pulls
    @client.pull_requests(@repo)
  end

  def add_assignee(number, assignee)
    @client.update_issue(@repo, number, :assignee => assignee)
  end

  def reviewer_comment(number, assignee, trello_card)
    @client.add_comment(@repo, number, "@#{assignee} is your reviewer :thumbsup: check #{trello_card.url}")
  end

  def unassigned_pull_requests
    list_pulls.select { |issue| !issue[:assignee] }
  end

end
