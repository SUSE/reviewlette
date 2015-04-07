require 'spec_helper'

describe TrelloConnection do

  TRELLO_CONFIG = { :consumerkey => '4a6', :consumersecret => '899', :oauthtoken => 'a8e', :board_id => 'T5S' }
  subject { TrelloConnection }
  let (:trello) { subject.new }
  let (:card) { Trello::Card.new }

  before {
    allow(Trello::Board).to receive(:find).and_return(Trello::Board.new)
  }

  describe '.new' do
    it 'sets up trello' do
      expect_any_instance_of(Trello::Configuration).to receive(:developer_public_key=).with(TRELLO_CONFIG['consumerkey'])
      expect_any_instance_of(Trello::Configuration).to receive(:member_token=).with(TRELLO_CONFIG['oauthtoken'])
      subject.new
    end
  end

  describe '#add_reviewer_to_card' do
    it "adds the valid member to the trello card and comments it" do
      expect(trello).to receive(:find_member_by_username).with('testuser1').and_return 'testuser1'
      expect_any_instance_of(Trello::Card).to receive(:add_member).with('testuser1')
      trello.add_reviewer_to_card('testuser1', card)
    end
  end

  describe '#comment_on_card' do
    it "comments on the assigned trello card " do
      allow(card).to receive(:add_comment).with('comment').and_return true
      expect(trello.comment_on_card('comment', card)).to eq true
    end
  end

  describe '#move_card_to_list' do
    it 'move cards to its certain column' do
      expect(trello).to receive(:find_column).with('Done').and_return 'column'
      expect(card).to receive(:move_to_list).with('column').and_return true
      expect(trello.move_card_to_list(card, 'Done')).to be true
    end
  end

  describe '#find_column' do
    it 'detects columns' do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:lists, :find)
      trello.find_column('Done')
    end
  end

  describe '#find_member_by_username' do
    it "finds a member based on a username and returns a trello member object" do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:members, :find)
      trello.find_member_by_username('testuser')
    end
  end

  describe '#find_card_by_id(id)' do
    it "finds the right card based on the trello id" do
      expect_any_instance_of(Trello::Board).to receive_message_chain(:cards, :find)
      trello.find_card_by_id(123)
    end
  end


end
