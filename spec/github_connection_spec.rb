require 'spec_helper'

describe GithubConnection do

  subject { GithubConnection }
  let(:connection) { subject.new(repo, token) }
  let(:repo) { 'test' }
  let(:token) { 'foo' }
  let(:member1) { { 'name' => 'test1', 'suse_username' => 'test1', 'github_username' => 'githubtest1' } }
  let(:member2) { { 'name' => 'test2', 'suse_username' => 'test2', 'github_username' => 'githubtest2' } }

  describe '.new' do
    it 'initializes octokit client and repo' do
      expect(Octokit::Client).to receive(:new).with(:access_token => token)
      expect(connection.repo).to eq(repo)
    end
  end

  describe '#add_assignees' do
    it 'adds assignees to the GitHub issue' do
      expect(connection.client).to receive(:update_issue).with(repo, 11, assignees: ['test'])
      connection.add_assignees(11, ['test'])
    end
  end

  describe '#comment_reviewers' do
    it 'comments on a given issue' do
      card      = Trello::Card.new
      reviewers = [member1, member2]

      allow(card).to receive(:url).and_return('url')
      expect(connection.client).to receive(:add_comment).with(repo, 11, anything)

      connection.comment_reviewers(11, reviewers, card)
    end
  end

  describe '#pull_requests' do
    it 'lists all pullrequests for a given repository' do
      expect(connection.client).to receive(:pull_requests).with(repo)
      connection.pull_requests
    end
  end

  describe '#repo_exists?' do
    it 'checks if a certain repository exists' do
      expect(connection.client).to receive(:repository?).with(repo)
      connection.repo_exists?
    end

  end
end
