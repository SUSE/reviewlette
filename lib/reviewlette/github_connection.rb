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
    @client.update_issue(@repo, number, assignee: assignee)
  end

  def reviewer_comment(number, assignee, trello_card)
    comment = "@#{assignee} is your reviewer :dancers: check #{trello_card.url} \n" \
              "@#{assignee}: Please review this pull request using our guidelines: \n" \
              "* test for acceptance criteria / functionality \n" \
              "* check if the new code is covered with tests \n" \
              "* check for unintended consequences \n" \
              "* encourage usage of the boyscout rule \n" \
              "* make sure the code is architected in the best way \n" \
              "* check that no unnecessary technical debt got introduced \n" \
              "* make sure that no unnecessary FIXMEs or TODOs got added \n"
    @client.add_comment(@repo, number, comment)
  end

  def unassigned_pull_requests
    list_pulls.select { |issue| !issue[:assignee] }
  end

end
