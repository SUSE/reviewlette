require 'spec_helper'

describe Reviewlette do
  subject { Reviewlette }

  let(:reviewlette)    { subject.new }

  let(:members_config) { { 'members' => [member1, member2] } }
  let(:member1)        { { 'name' => 'test1', 'suse_username' => 'test1', 'trello_username' => 'trellotest1' } }
  let(:member2)        { { 'name' => 'test2', 'suse_username' => 'test2', 'trello_username' => 'trellotest2' } }

  let(:github_config)  { { token: token, repos: [repo, repo2] } }
  let(:token)          { '1234' }
  let(:repo)           { 'SUSE/test' }
  let(:repo2)          { 'SUSE/foo' }

  before do
    allow(TrelloConnection).to receive(:new).and_return TrelloConnection
    allow(GithubConnection).to receive(:new).with(repo, token).and_return GithubConnection
    allow(YAML).to receive(:load_file).with(/github\.yml/).and_return github_config
    allow(YAML).to receive(:load_file).with(/members\.yml/).and_return members_config
  end

  describe '.new' do
    it 'sets trello connections' do
      expect(TrelloConnection).to receive(:new)
      subject.new
    end
  end

  describe '.run' do
    it 'iterates over all open repositories and looks for unassigned pull requests' do
      github_config[:repos].each do |r|
        expect(reviewlette).to receive(:check_repo).with(r, token)
        reviewlette.check_repo(r, token)
      end
    end
  end

  describe '.check_repo' do
    it 'skips repo when invalid' do
      expect(GithubConnection).to receive(:repo_exists?).and_return false
      expect { reviewlette.check_repo(repo, token) }.to output(/does not exist/).to_stdout
    end

    it 'iterates over all open pull requests and extracts trello ids from name' do
      expect(GithubConnection).to receive(:repo_exists?).and_return true
      expect(GithubConnection).to receive(:unassigned_pull_requests).and_return([{number: 11, title: 'test_issue_12'}])
      expect(TrelloConnection).to receive(:find_card_by_id).with(12)

      reviewlette.check_repo(repo, token)
    end

    it 'iterates over all open pr and skip pr with no card id' do
      expect(GithubConnection).to receive(:repo_exists?).and_return true
      expect(GithubConnection).to receive(:unassigned_pull_requests).and_return([{ number: 11, title: 'no card id' }])

      expect { reviewlette.check_repo(repo, token) }.to output(/Pull request not assigned to a trello card/).to_stdout
    end

    it 'adds assignee and reviewer comment on github, adds comment on trello and moves card' do
      card        = Trello::Card.new
      user        = { 'suse_username' => 'test', 'github_username' => 'testgit', 'trello_username' => 'testtrello' }
      pullrequest = { number: 11, title: 'test_issue_12' }

      expect(GithubConnection).to receive(:repo_exists?).and_return true
      expect(GithubConnection).to receive(:unassigned_pull_requests).and_return([pullrequest])
      expect(TrelloConnection).to receive(:find_card_by_id).with(12).and_return(card)
      expect(reviewlette).to receive(:select_reviewers).and_return([user])

      expect(GithubConnection).to receive(:add_assignee).with(11, 'testgit')
      expect(GithubConnection).to receive(:comment_reviewers).with(11, [user], card)

      expect(TrelloConnection).to receive(:comment_reviewers).with(card, 'SUSE/test', 11, [user])
      expect(TrelloConnection).to receive(:move_card_to_list).with(card, 'In review')

      reviewlette.check_repo(repo, token)
    end

    it 'does not find a reviewer' do

      card = Trello::Card.new

      expect(GithubConnection).to receive(:repo_exists?).and_return true
      expect(GithubConnection).to receive(:unassigned_pull_requests).and_return([{ number: 11, title: 'test_issue_12' }])
      expect(TrelloConnection).to receive(:find_card_by_id).with(12).and_return(card)
      expect(reviewlette).to receive(:select_reviewers).and_return []

      expect { reviewlette.check_repo(repo, token) }.to output(/Could not find a reviewer/).to_stdout
    end

  end

  describe '.scan_flags' do
    subject { Reviewlette.new.scan_flags(title) }

    context 'title with flags' do
      let(:title) { '[foo, bar, baz] title' }
      it { is_expected.to eq(['foo', 'bar', 'baz']) }
    end

    context 'title with no flags' do
      let(:title) { 'title' }
      it { is_expected.to eq([]) }
    end
  end

  describe '.select_reviewers' do
    it 'excludes members on vacation' do
      card       = Trello::Card.new

      allow(card).to receive(:members).and_return([])
      expect(Vacations).to receive(:members_on_vacation).and_return([member1['suse_username']])
      expect(reviewlette.select_reviewers(card, 1)).to eq([member2])
    end

    it 'excludes the owner of the trello card' do
      card = Trello::Card.new
      reviewers = [member1, member2]

      expect(Vacations).to receive(:members_on_vacation).and_return([])
      allow(card).to receive_message_chain(:members, :map).and_return(reviewers)
      expect(reviewlette.select_reviewers(card).size).to eq(1)
    end

    it 'selects n reviewers' do
      card = Trello::Card.new

      allow(card).to receive_message_chain(:members, :map).and_return([member1])
      expect(Vacations).to receive(:members_on_vacation).and_return([])
      expect(reviewlette.select_reviewers(card, 2)).to match_array([member1, member2])
    end

    it 'selects only one reviewer if no second is available' do
      card = Trello::Card.new
      allow(card).to receive_message_chain(:members, :map).and_return([member1, member2])
      expect(Vacations).to receive(:members_on_vacation).and_return(['test1'])
      expect(reviewlette.select_reviewers(card, 2)).to eq([member2])
    end
  end

  describe '.how_many_should_review' do
    subject { Reviewlette.new.how_many_should_review(flags) }

    context 'flags include an exclamation mark' do
      let(:flags) { ['foo', '!', 'bar'] }
      it { is_expected.to eq(2) }
    end

    context 'flags do not include an exclamation mark' do
      let(:flags) { ['foo', 'baz', 'bar'] }
      it { is_expected.to eq(1) }
    end
  end
end
