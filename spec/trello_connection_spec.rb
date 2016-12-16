require 'spec_helper'

describe Reviewlette::TrelloConnection do
  subject { described_class.new }
  let(:card)          { Trello::Card.new }
  let(:trello_config) { { 'consumerkey' => consumerkey, 'oauthtoken' => oauthtoken } }
  let(:consumerkey)   { '4a6' }
  let(:oauthtoken)    { 'a8e' }

  before do
    allow(Trello::Board).to receive(:find).and_return(Trello::Board.new)
    allow(YAML).to receive(:load_file).and_return(trello_config)
  end

  describe '.new' do
    it 'sets up trello' do
      expect_any_instance_of(Trello::Configuration).to receive(:developer_public_key=).with(consumerkey)
      expect_any_instance_of(Trello::Configuration).to receive(:member_token=).with(oauthtoken)
      described_class.new
    end
  end

  describe '#add_reviewer_to_card' do
    it 'adds the valid member to the trello card and comments it' do
      expect(subject).to receive(:find_member_by_username).with('testuser1').and_return 'testuser1'
      expect_any_instance_of(Trello::Card).to receive(:add_member).with('testuser1')
      subject.add_reviewer_to_card('testuser1', card)
    end
  end

  describe '#comment_reviewers' do
    it 'comments on the assigned trello card ' do
      repo_name = 'testrepo'
      issue_id  = 1
      reviewers = [double(trello_handle: 'test1'), double(trello_handle: 'test2')]
      comment   = "@test1 and @test2 will review https://github.com/#{repo_name}/issues/#{issue_id}"

      allow(card).to receive(:add_comment).with(comment).and_return true
      expect(subject.comment_reviewers(card, repo_name, issue_id, reviewers)).to eq true
    end
  end

  describe '#move_card_to_list' do
    it 'move cards to its certain column' do
      expect(subject).to receive(:find_column).with('Done').and_return 'column'
      expect(card).to receive(:move_to_list).with('column').and_return true
      expect(subject.move_card_to_list(card, 'Done')).to be true
    end
  end

  describe '#find_column' do
    it 'detects columns' do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:lists, :find)
      subject.find_column('Done')
    end
  end

  describe '#find_member_by_username' do
    it 'finds a member based on a username and returns a trello member object' do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:members, :find)
      subject.find_member_by_username('testuser')
    end
  end

  describe '#find_card_by_id(id)' do
    it 'finds the right card based on the trello id' do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:cards, :find)
      subject.find_card_by_id(123)
    end
  end
end
