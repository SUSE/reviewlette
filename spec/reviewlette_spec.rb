require 'spec_helper'

describe Reviewlette do
  let(:instance) { described_class.new members: [member1, member2] }
  subject { instance }

  let(:member1) { double(name: 'test1', github_handle: 'pinky', trello_handle: 'trellotest1') }
  let(:member2) { double(name: 'test2', github_handle: 'brain', trello_handle: 'trellotest2') }

  let(:github_config)  { { token: token, repos: [repo, repo2] } }
  let(:token)          { '1234' }
  let(:repo)           { 'SUSE/test' }
  let(:repo2)          { 'SUSE/foo' }

  before do
    allow(described_class::TrelloConnection).to receive(:new).and_return described_class::TrelloConnection
    allow(described_class::GithubConnection).to receive(:new).with(repo, token).and_return described_class::GithubConnection
    allow(YAML).to receive(:load_file).with(/github\.yml/).and_return github_config
  end

  describe '.new' do
    it 'sets trello connections' do
      expect(described_class::TrelloConnection).to receive(:new)
      subject
    end
  end

  describe '.run' do
    it 'iterates over all open repositories and looks for unassigned pull requests' do
      github_config[:repos].each do |r|
        expect(subject).to receive(:check_repo).with(r, token)
        subject.check_repo(r, token)
      end
    end
  end

  describe '.check_repo' do
    context 'invalid repo' do
      it 'skips the repo' do
        expect(described_class::GithubConnection).to receive(:repo_exists?).and_return false
        expect { subject.check_repo(repo, token) }.to output(/does not exist/).to_stdout
      end
    end

    it 'iterates over all open pull requests and extracts trello ids from name' do
      expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
      expect(described_class::GithubConnection).to receive(:pull_requests).and_return([{number: 11, title: 'test_issue_12'}])
      expect(described_class::GithubConnection).to receive(:labels).and_return([])
      expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(12)

      subject.check_repo(repo, token)
    end

    it 'iterates over all pull requests and skips those with no card id' do
      expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
      expect(described_class::GithubConnection).to receive(:pull_requests).and_return([{ number: 11, title: 'no card id' }])
      expect(described_class::GithubConnection).to receive(:labels).and_return([])

      expect { subject.check_repo(repo, token) }.to output(/Pull request not assigned to a trello card/).to_stdout
    end

    it 'adds assignees and reviewers comment on github, adds comment on trello and moves card' do
      card        = Trello::Card.new
      user        = double(github_handle: 'testgit', trello_handle: 'testtrello')
      pullrequest = { number: 11, title: 'test_issue_12', assignees: [] }

      expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
      expect(described_class::GithubConnection).to receive(:pull_requests).and_return([pullrequest])
      expect(described_class::GithubConnection).to receive(:labels).and_return([])
      expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(12).and_return(card)
      expect(subject).to receive(:select_reviewers).and_return([user])

      expect(described_class::GithubConnection).to receive(:add_assignees).with(11, ['testgit'])
      expect(described_class::GithubConnection).to receive(:comment_reviewers).with(11, [user], card)

      expect(described_class::TrelloConnection).to receive(:comment_reviewers).with(card, 'SUSE/test', 11, [user])
      expect(described_class::TrelloConnection).to receive(:move_card_to_list).with(card, 'In review')

      subject.check_repo(repo, token)
    end

    context 'pull request with one reviewer but two wanted' do
      it 'selects a second reviewer' do
        card = Trello::Card.new
        pullrequest = { number: 11, title: 'pr title 42', assignees: [OpenStruct.new({login: 'pinky'})] }
        expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
        expect(described_class::GithubConnection).to receive(:pull_requests).and_return([pullrequest])
        expect(described_class::GithubConnection).to receive(:labels).and_return(['2 reviewers'])
        expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(42).and_return(card)

        expect(described_class::GithubConnection).to receive(:add_assignees).with(11, ['pinky', 'brain'])
        expect(described_class::GithubConnection).to receive(:comment_reviewers).with(11, [member1, member2], card)
        expect(described_class::TrelloConnection).to receive(:comment_reviewers).with(card, repo, 11, [member1, member2])
        expect(described_class::TrelloConnection).to receive(:move_card_to_list).with(card, 'In review')
        expect(subject).to receive(:select_reviewers).with(card, 2, [member1]).and_return([member1, member2])
        subject.check_repo(repo, token)
      end
    end

    context 'pull request with two reviewers but no "2 reviewers" label' do
      it 'keeps both reviewers' do
        card = Trello::Card.new
        pullrequest = { number: 11, title: 'pr title 42', assignees: [ OpenStruct.new({login: 'pinky'}), OpenStruct.new({login: 'brain'})] }
        expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
        expect(described_class::GithubConnection).to receive(:pull_requests).and_return([pullrequest])
        expect(described_class::GithubConnection).to receive(:labels).and_return([])
        expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(42).and_return(card)

        expect(described_class::GithubConnection).not_to receive(:add_assignees)
        expect(described_class::TrelloConnection).not_to receive(:move_card_to_list).with(card, 'In review')
        subject.check_repo(repo, token)
      end
    end

    context 'pull request with already correct number of reviewers' do
      it 'does not assign nor comment in GitHub or Trello' do
        card = Trello::Card.new
        pullrequest = { number: 11, title: 'pr title 42', assignees: [ OpenStruct.new({login: 'pinky'}), OpenStruct.new({login: 'pinky'})] }
        expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
        expect(described_class::GithubConnection).to receive(:pull_requests).and_return([pullrequest])
        expect(described_class::GithubConnection).to receive(:labels).and_return(['2 reviewers'])
        expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(42).and_return(card)

        expect(described_class::GithubConnection).not_to receive(:add_assignees)
        expect(described_class::GithubConnection).not_to receive(:comment_reviewers)
        expect(described_class::TrelloConnection).not_to receive(:comment_reviewers)
        expect(described_class::TrelloConnection).not_to receive(:move_card_to_list).with(card, 'In review')
        subject.check_repo(repo, token)
      end
    end

    it 'does not find a reviewer' do
      card = Trello::Card.new

      expect(described_class::GithubConnection).to receive(:repo_exists?).and_return true
      expect(described_class::GithubConnection).to receive(:pull_requests).and_return([{ number: 11, title: 'test_issue_12', assignees: [] }])
      expect(described_class::GithubConnection).to receive(:labels).and_return([])
      expect(described_class::TrelloConnection).to receive(:find_card_by_id).with(12).and_return(card)
      expect(subject).to receive(:select_reviewers).and_return []

      expect { subject.check_repo(repo, token) }.to output(/Could not find a reviewer/).to_stdout
    end

  end

  describe '.select_reviewers' do
    it 'excludes the owner of the trello card' do
      card = Trello::Card.new
      reviewers = [member1, member2]

      allow(card).to receive_message_chain(:members, :map).and_return(reviewers)
      expect(subject.select_reviewers(card).size).to eq(1)
    end

    it 'selects n reviewers' do
      card = Trello::Card.new

      allow(card).to receive_message_chain(:members, :map).and_return([member1])
      expect(subject.select_reviewers(card, 2)).to match_array([member1, member2])
    end

    it 'selects only one reviewer if no second is available' do
      card = Trello::Card.new

      allow(card).to receive_message_chain(:members, :map).and_return([member2.trello_handle])
      expect(subject.select_reviewers(card, 2)).to eq([member1])
    end
  end

  describe '.how_many_should_review' do
    subject { instance.how_many_should_review(labels) }

    context 'with "2 reviewers" label' do
      let(:labels) { ['foo', '2 reviewers', 'bar'] }
      it { is_expected.to eq(2) }
    end

    context 'with no "2 reviewers" label' do
      let(:labels) { ['foo', 'bar'] }
      it { is_expected.to eq(1) }
    end
  end
end
