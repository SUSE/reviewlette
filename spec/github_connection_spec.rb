require 'spec_helper'

describe GithubConnection do

  subject { GithubConnection }
  let( :connection ) { subject.new(repo, token) }
  let( :repo ) { "test" }
  let( :token ) { "foo" }

  describe '.new' do
    it 'initializes octokit client and repo' do
      expect(Octokit::Client).to receive(:new).with(:access_token => token)
      expect(connection.repo).to eq(repo)
    end
  end

  describe '#add_assignee' do
    it 'adds an assignee to the gh issue' do
      expect(connection.client).to receive(:update_issue).with(repo, 11, :assignee => 'test')
      connection.add_assignee(11, 'test')
    end
  end

  describe '#reviewer_comment' do
    it 'comments on a given issue' do
      card = Trello::Card.new
      allow(card).to receive(:url).and_return('url')
      expect(connection.client).to receive(:add_comment).with(repo, 11, anything)
      connection.reviewer_comment(11, 'test', card)
    end
  end

  describe '#list_pulls' do
    it 'lists all pullrequests for a given repository' do
      expect(connection.client).to receive(:pull_requests).with(repo)
      connection.list_pulls
    end
  end

  describe '#repo_exists?' do
    it 'checks if a certain repository exists' do
      expect(connection.client).to receive(:repository?).with(repo)
      connection.repo_exists?
    end

  end
end
