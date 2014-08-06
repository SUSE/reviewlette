require 'spec_helper'

describe Reviewlette::GithubConnection do

  subject { Reviewlette::GithubConnection }

  describe '.new' do

    it 'populates @repo with repo string' do
      expect(subject.new.repo).to be_a_kind_of String
    end

    it 'sets up Github connection' do
      config = Reviewlette::GithubConnection::GITHUB_CONFIG
      expect(Octokit::Client).to receive(:new).with(:access_token => config['token'])
      subject.new
    end
  end

  describe '#pull_merged?' do
    let( :connection ) { subject.new }

    it 'checks if the pull is merged' do
      allow(connection.client).to receive(:pull_merged?).with('true', 6).and_return true
      expect(connection.pull_merged?('true', 6)).to be true
    end

    it 'checks if the pull is not merged' do
      allow(connection.client).to receive(:pull_merged?).with('false', 5).and_return false
      expect(connection.pull_merged?('false', 5)).to be false
    end
  end

  describe '#add_assignee' do
    let( :connection ) { subject.new }

    it 'adds an assignee to the gh issue' do
      params = [4, 'title', 'body', 'name']
      params2 = [connection.repo, 4, 'title', 'body',  :assignee => 'name']
      allow(connection.client).to receive(:update_issue).with(*params2).and_return true
      expect(connection.add_assignee(*params)).to eq true
    end

    it 'fails to add an assignee to the gh issue' do
      params = [4, 'title', 'body', 'name']
      params2 = [connection.repo, 4, 'title', 'body',  :assignee => 'name']
      allow(connection.client).to receive(:update_issue).with(*params2).and_return false
      expect(connection.add_assignee(*params)).to eq false
    end
  end

  describe '#comment_on_issue' do
    let( :connection ) { subject.new }

    it 'comments on a given issue' do
      params = [connection.repo, 4, '@name is your reviewer :thumbsup: check url']
      params2 = [4, 'name', 'url']
      allow(connection.client).to receive(:add_comment).with(*params).and_return true
      expect(connection.comment_on_issue(*params2)).to eq true
    end

    it 'fails to comment on a given issue and fails' do
      params = [connection.repo, 4, '@name is your reviewer :thumbsup: check url']
      params2 = [4, 'name', 'url']
      allow(connection.client).to receive(:add_comment).with(*params).and_return false
      expect(connection.comment_on_issue(*params2)).to eq false
    end
  end

  describe '#list_issues' do
    let( :connection ) { subject.new }

    it 'fails to determine if an assignee is set' do
      allow(connection.client).to receive_message_chain(:list_issues)
      connection.list_issues(connection.repo)
    end
  end

  describe '#team' do
    let( :connection ) { subject.new }

    it '#team' do
      expect(connection.team).to be_a_kind_of Array
    end
  end

  describe '#list_pulls' do
    let( :connection ) { subject.new }

    it 'lists a pullrequests for a given repository' do
      expect(connection.client).to receive(:pull_requests)
      connection.list_pulls(connection.repo)
    end
  end

  describe '#get_branch_name' do
    let( :connection ) { subject.new }

    it 'get branch name based on a repo and a pullrequest id' do
      pulls = [double({ 'head' => double({ 'ref' => 'number'})})]
      pr = pulls.first
      expect(connection.client).to receive(:pull_requests).with(connection.repo).and_return pulls
      expect(pulls).to receive(:[]).with(3).and_return pr
      expect(pr).to receive(:head).and_return pr.head
      connection.get_branch_name(3, connection.repo)
    end
  end
end
