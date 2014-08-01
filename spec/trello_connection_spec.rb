require 'spec_helper'

describe Reviewlette::TrelloConnection do

  subject { Reviewlette::TrelloConnection }

  describe '.new' do

    it 'populates board variable with instance of Trello::Board' do
      stub_boards_call
      expect(subject.new.board).to be_kind_of Trello::Board
    end

    it 'sets up trello' do
      allow(Trello::Board).to receive(:find).and_return nil
      config = Reviewlette::TRELLO_CONFIG1
      expect_any_instance_of(Trello::Configuration).to receive(:developer_public_key=).with(config['consumerkey']).and_call_original
      subject.new
    end

    it 'sets up trello' do
      allow(Trello::Board).to receive(:find).and_return nil
      config = Reviewlette::TRELLO_CONFIG1
      expect_any_instance_of(Trello::Configuration).to receive(:member_token=).with(config['oauthtoken']).and_call_original
      subject.new
    end

  end

  describe '#find_card' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "conforms to the card id with specific structure" do
      expect(trello_connection.find_card("asd")).to be nil
    end

    it "conforms to the card id with specific structure" do
      line = "Review_1337_name_of_pr_trello_shortid_454"
      expect(trello_connection.find_card(line)).to eql '454'
    end
  end

  describe '#find_member_by_id(id)' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow(subject).to receive(:find_card_by_id).and_return :id
    end

    it "finds the right card based on the trello id" do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:cards, :find)
      trello_connection.send(:find_card_by_id, 42)
      #privates with send
    end
  end

  describe '#find_member_by_username' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow(subject).to receive(:find_member_by_username).and_return :username
    end

    it "finds a member based on a username and returns a trello member object" do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:members, :find)
      trello_connection.send(:find_member_by_username, 'art')
    end
  end

  describe '#find_member_by_id' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow(subject).to receive(:find_member_by_id).and_return :id
    end

    it "finds the right member based on the trello id and returns a trello member object" do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:members, :find)
      trello_connection.send(:find_member_by_id, 42)
    end
  end

  describe '#add_reviewer_to_card' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "adds the valid member to the trello card and comments it" do
      card = double('card')
      allow(card).to receive(:add_member).and_return true
      expect(trello_connection.add_reviewer_to_card('asd', card)).to eq true
    end
  end

  describe '#comment_on_card' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "comments on the assigned trello card " do
      card = double('card')
      allow(card).to receive(:add_comment).with('username').and_return true
      expect(trello_connection.comment_on_card('username', card)).to eq true
    end
  end

  describe '#team' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "builds the team member list" do
      expect(trello_connection.team).to be_a_kind_of Array
    end
  end

  describe '#move_card_to_list' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it 'move cards to its certain column' do
      card = double('card')
      allow(card).to receive(:move_to_list).with('Done').and_return true
      expect(trello_connection.move_card_to_list(card, 'Done')).to be true
    end

    it 'fails to  move cards to its certain column' do
      card = double('card')
      allow(card).to receive(:move_to_list).with('Done').and_return false
      expect(trello_connection.move_card_to_list(card, 'Done')).to be false
    end
  end

  describe '#find_column' do
    let( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it 'detects columns' do
      board = double('board')
      trello_connection.board = board
      expect(board).to receive_message_chain(:lists, :find)
      trello_connection.send(:find_column, 'Done')
    end
  end

  describe '#sample_reviewer' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end
    it 'randomly selects a teammember' do
      card = double('card')
      expect(card).to receive_message_chain(:assignees, :map).and_return ['funny','names']
      trello_connection.sample_reviewer(card)
    end
  end

  describe '#reviewer_exception_handler' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end
    it 'checks sum of for card assignees' do
      card = double('card')
      expect(card).to receive_message_chain(:assignees, :map).and_return [1,2,3]
      trello_connection.reviewer_exception_handler(card)
    end
  end

  describe '#determine_reviewer' do
    let ( :trello_connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it 'fails to holds an array of the available reveiewers' do
      card = double('card')
      expect(trello_connection).to receive(:reviewer_exception_handler).with(card).and_return true
      expect{trello_connection.determine_reviewer(card)}.to raise_error(Exception, 'Everyone on the team is assigned to the Card.')
    end

    it 'holds an array of the available reveiewers' do
      card = double('card')
      expect(trello_connection).to receive(:reviewer_exception_handler).with(card).and_return false
      expect(trello_connection).to receive(:sample_reviewer).and_return true
      expect(trello_connection).to receive(:find_member_by_username).and_return 'name'
      expect(trello_connection.determine_reviewer(card)).to eq 'name'
    end
  end
end
