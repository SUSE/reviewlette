require 'spec_helper'

describe Reviewlette::GithubConnection do
  subject { described_class.new(repo, token) }
  let(:repo) { 'test' }
  let(:token) { 'foo' }
  let(:member1) { double(name: 'test1', github_handle: 'githubtest1') }
  let(:member2) { double(name: 'test2', github_handle: 'githubtest2') }

  describe '.new' do
    it 'initializes octokit client and repo' do
      expect(Octokit::Client).to receive(:new).with(:access_token => token)
      expect(subject.repo).to eq(repo)
    end
  end

  describe '#add_assignees' do
    it 'adds assignees to the GitHub issue' do
      expect(subject.client).to receive(:update_issue).with(repo, 11, assignees: ['test'])
      subject.add_assignees(11, ['test'])
    end
  end

  describe '#comment_reviewers' do
    it 'comments on a given issue' do
      card      = Trello::Card.new
      reviewers = [member1, member2]

      allow(card).to receive(:url).and_return('url')
      expect(subject.client).to receive(:add_comment).with(repo, 11, anything)

      subject.comment_reviewers(11, reviewers, card)
    end
  end

  describe '#pull_requests' do
    it 'lists all pullrequests for a given repository' do
      expect(subject.client).to receive(:pull_requests).with(repo)
      subject.pull_requests
    end
  end

  describe '#repo_exists?' do
    it 'checks if a certain repository exists' do
      expect(subject.client).to receive(:repository?).with(repo)
      subject.repo_exists?
    end

  end
end
