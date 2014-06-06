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
      params = [connection.repo, 4, 'name is your reviewer :thumbsup:']
      params2 = [4, 'name']
      allow(connection.client).to receive(:add_comment).with(*params).and_return true
      expect(connection.comment_on_issue(*params2)).to eq true
    end

    it 'fails to comment on a given issue and fails' do
      params = [connection.repo, 4, 'name is your reviewer :thumbsup:']
      params2 = [4, 'name']
      allow(connection.client).to receive(:add_comment).with(*params).and_return false
      expect(connection.comment_on_issue(*params2)).to eq false
    end
  end

  describe '#assigned?' do
    let( :connection ) { subject.new }

    it 'determine if an assignee is set ' do
      #how to check @number e.g. to contain a hash
    end

    it 'fails to determine if an assignee is set' do
      allow(connection.client).to receive_message_chain(:list_issues, :each)
      connection.assigned?(connection.repo)
    end
  end

  describe '#move_card_to_list' do
    let( :connection ) { subject.new }

    it 'move cards to its certain column' do
      card = double('card')
      allow(card).to receive(:move_to_list).with('Done').and_return true
      expect(connection.move_card_to_list(card, 'Done')).to be true
    end

    it 'fails to  move cards to its certain column' do
      card = double('card')
      allow(card).to receive(:move_to_list).with('Done').and_return false
      expect(connection.move_card_to_list(card, 'Done')).to be false
    end
  end
end