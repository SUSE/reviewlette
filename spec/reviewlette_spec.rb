require 'spec_helper'

describe Reviewlette do

  # set instance variable from local variable
  def instance_variable!(variable_name)
    Reviewlette.instance_variable_set("@#{variable_name}", send(variable_name.to_sym))
  end

  let(:number) { 23 }
  let(:title) { 'title' }
  let(:body) { 'body' }
  let(:githubname) { 'gitty' }
  let(:trelloname) { 'jschmid' }
  let(:github_stub) { github_stub }
  let(:board) { stub_boards_call }
  let(:repo) { 'repo/repo' }
  let(:id) { 23 }
  let(:card) { stub_card_call }
  let(:logger) { double 'logger' }
  let(:trello_connection) { double 'trello_connection' }
  let(:reviewer) {double 'reviewer'}
  let(:github_connection) { double 'github_connection' }
  let(:full_comment) { @full_comment = "@#{trelloname} will review https://github.com/#{repo}/issues/#{number.to_s}" }


  describe '.spin' do
    before do
      instance_variable! :github_connection
      instance_variable! :repo
      instance_variable! :trello_connection
      instance_variable! :id
      instance_variable! :title
      instance_variable! :body
      instance_variable! :number
      instance_variable! :logger
      issue = { number: 1, title: 'Title', body: 'Body' }
      expect(Reviewlette).to receive(:setup)
      expect(Reviewlette).to receive(:get_unassigned_github_issues).and_return [issue]
      expect(Reviewlette).to receive(:find_card)
    end

    it 'spins until find_id' do
      expect(Reviewlette).to receive(:find_id).and_return false
      expect(Reviewlette).to_not receive(:set_reviewer)
      expect(Reviewlette).to_not receive(:transform_name)
      expect(Reviewlette).to_not receive(:add_reviewer_on_github)
      expect(Reviewlette).to_not receive(:comment_on_github)
      expect(Reviewlette).to_not receive(:add_to_trello_card)
      expect(Reviewlette).to_not receive(:comment_on_trello)
      expect(Reviewlette).to_not receive(:move_to_list)
      expect(Reviewlette).to_not receive(:comment_on_error)
      Reviewlette.spin
    end

    it 'spins until set_reviewer' do
      expect(Reviewlette).to receive(:find_id).and_return true
      expect(Reviewlette).to receive(:set_reviewer)
      expect(Reviewlette).to_not receive(:transform_name)
      expect(Reviewlette).to_not receive(:add_reviewer_on_github)
      expect(Reviewlette).to_not receive(:comment_on_github)
      expect(Reviewlette).to_not receive(:add_to_trello_card)
      expect(Reviewlette).to_not receive(:comment_on_trello)
      expect(Reviewlette).to_not receive(:move_to_list)
      expect(Reviewlette).to receive(:comment_on_error)
      Reviewlette.spin
    end

    it 'spins until set_reviewer' do
      expect(Reviewlette).to receive(:find_id).and_return true
      expect(Reviewlette).to receive(:set_reviewer).and_return true
      expect(Reviewlette).to receive(:transform_name)
      expect(Reviewlette).to receive(:add_reviewer_on_github)
      expect(Reviewlette).to receive(:comment_on_github)
      expect(Reviewlette).to receive(:add_to_trello_card)
      expect(Reviewlette).to receive(:comment_on_trello)
      expect(Reviewlette).to receive(:move_to_list)
      expect(Reviewlette).to_not receive(:comment_on_error)
      Reviewlette.spin
    end
  end

  describe '#find_card' do

    it 'finds the card by Github title' do
      expect(Reviewlette).to receive(:find_card)
      Reviewlette.find_card
    end

    it 'finds the card by Github title' do
      line = 'Review_1337_name_of_pr_trello_shortid_454'
      expect(Reviewlette.find_card(line)).to eq true
    end

    it 'finds the card by Github title' do
      line = 'Review_1337_name_of_pr_trello_shortid'
      expect(Reviewlette.find_card(line)).to eq false
    end
  end

  describe '.comment_on_error' do
    it 'posts a comment with the arror message on trello' do
      instance_variable! :trello_connection
      expect(trello_connection).to receive(:comment_on_card).with("Skipped Issue 1 because everyone on the team is assigned to the card", nil)
      Reviewlette.comment_on_error
    end

  end

  describe '.get_unassigned_github_issues' do
    it 'returns all unassigned issues' do
    instance_variable! :github_connection
    expect(github_connection).to receive_message_chain(:list_issues, :select)
    Reviewlette.get_unassigned_github_issues
    end
  end


  describe '.transform_name' do
    it 'transforms trelloname to github name' do
      instance_variable! :trelloname
      Reviewlette.transform_name
      expect(Reviewlette.instance_variable_get("@githubname")).to be_a_kind_of String
    end
  end

  describe '.find_id' do
    before do
      instance_variable! :id
      instance_variable! :trello_connection
    end

    it 'finds the id' do
      expect(trello_connection).to receive(:find_card_by_id).with(id).and_return card
      Reviewlette.find_id
    end

    it 'does not find the id' do
      Reviewlette.instance_variable_set("@id", 0)
      Reviewlette.instance_variable_set("@logger", logger)
      expect(logger).to receive(:warn)
      expect(Reviewlette.find_id).to be false
    end
  end

  describe '.set_reviewer' do
    it 'sets the reviewer' do
      instance_variable! :trello_connection
      instance_variable! :card
      expect(trello_connection).to receive(:determine_reviewer).with(card).and_return reviewer
      expect(reviewer).to receive(:username).and_return String
      expect(reviewer).to receive(:username).and_return String
      Reviewlette.set_reviewer
    end

    it 'fails to set the reviewer because everyone on the team is assigned to the card' do
      instance_variable! :trello_connection
      instance_variable! :card
      expect { Reviewlette.set_reviewer }.to raise_error
    end
  end

  describe '.add_reviewer_on_github' do
    it 'adds the reviewer on github as assignee' do
      instance_variable! :github_connection
      instance_variable! :title
      instance_variable! :body
      instance_variable! :number
      instance_variable! :githubname
      expect(github_connection).to receive(:add_assignee).with(23, 'title', 'body', 'gitty').and_return true
      Reviewlette.add_reviewer_on_github
    end
  end

  describe '.comment_on_github' do
    it 'comments on the issue' do
      instance_variable! :card
      instance_variable! :number
      instance_variable! :githubname
      instance_variable! :github_connection
      expect(card).to receive(:url).and_return 'www.example.url'
      expect(github_connection).to receive(:comment_on_issue).with(23, 'gitty', 'www.example.url').and_return true
      Reviewlette.comment_on_github
    end
  end

  describe '.add_to_trello_card' do
    it 'adds a reviewer to the right trello card' do
      instance_variable! :trello_connection
      instance_variable! :reviewer
      instance_variable! :card
      expect(trello_connection).to receive(:add_reviewer_to_card).with(reviewer, card).and_return true
      Reviewlette.add_to_trello_card
    end

    it 'rescues with: already assigned' do
      instance_variable! :trello_connection
      expect{Reviewlette.add_to_trello_card}.to raise_exception
      # Reviewlette.add_to_trello_card
    end
  end

  describe '.comment_on_trello' do
    before do
      instance_variable! :repo
      instance_variable! :trelloname
      instance_variable! :number
      instance_variable! :trello_connection
      instance_variable! :full_comment
      instance_variable! :card
    end

    it 'puts a comment on the trello card ' do
      expect(full_comment).to eq '@jschmid will review https://github.com/repo/repo/issues/23'
    end

    it 'actually posts' do
      expect(trello_connection).to receive(:comment_on_card).with(full_comment, card).and_return true
      Reviewlette.comment_on_trello
    end
  end

  describe '.move_to_list' do
    before do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :card
      instance_variable! :repo
      instance_variable! :id
    end

    it 'moves the card to #Done list if the pull is merged' do
      expect(trello_connection).to receive(:find_column).with('Done').and_return 'Done'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'Done').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return true
      Reviewlette.move_to_list
    end

    it 'moves the card to #in-Review list if the pull is not merged' do
      expect(trello_connection).to receive(:find_column).with('In review').and_return 'In review'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'In review').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return false
      Reviewlette.move_to_list
    end
  end

  describe '.setup' do
    before do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :board
      instance_variable! :repo
    end

    it 'sets up repo variable' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@repo')).to be_kind_of String #ok
    end
    it 'sets up the github_connection' do
      Reviewlette.setup
      expect(github_connection).to be_kind_of Object #how to call this kind of structure
    end

    it 'sets up the trello_connection' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@trello_connection')).to be_kind_of Object #same
    end

    it 'sets up the board' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@board')).to be_kind_of Object #same
    end
  end
end
