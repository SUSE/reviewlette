require 'spec_helper'

describe Reviewlette::TrelloConnection do

  subject { Reviewlette::TrelloConnection }

  describe '.new' do

    it 'populates board variable with instance of Trello::Board' do
      stub_boards_call
      expect(subject.new.board).to be_kind_of Trello::Board
    end

    it 'setup trello properly' do
      allow(Trello::Board).to receive(:find).and_return nil
      config = Reviewlette::TrelloConnection::TRELLO_CONFIG
      expect_any_instance_of(Trello::Configuration).to receive(:developer_public_key=).with(config['consumerkey']).and_call_original
      subject.new
    end

    it 'setup trello properly' do
      allow(Trello::Board).to receive(:find).and_return nil
      config = Reviewlette::TrelloConnection::TRELLO_CONFIG
      expect_any_instance_of(Trello::Configuration).to receive(:member_token=).with(config['oauthtoken']).and_call_original
      subject.new
    end

  end

  describe '#find_card' do

    let( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true


    end

    it "conforms to the card id with specific structure" do
      expect(connection.find_card("asd")).to be nil
    end

    it "conforms to the card id with specific structure" do
      line = "Review_1337_name_of_pr_trello_shortid_454"
      allow(connection).to receive(:find_card_by_id).with('454').and_return :asd
      expect(connection.find_card(line)).to eq :asd
    end

    it "conforms to the card id with specific structure" do
      line = "Review_1337_name_of_pr_trello_shortid_454"
      expect(connection).to receive(:find_card_by_id).with('454').and_return :asd
      connection.find_card(line)
    end
  end

  describe '#find_member_by_id(id)' do

    let( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow(subject).to receive(:find_card_by_id).and_return :id
    end

    it "finds the right card based on the trello id" do
      board = double('board')
      connection.board = board
      expect(board).to receive_message_chain(:cards, :find)
      connection.send(:find_card_by_id, 42)
      #privates with send
    end

    it "finds the right card based on the trello id and returns a trello member object" do
      id = 54
      allow(connection).to receive(:find_card_by_id).with(id).and_return :id
      expect(connection.find_card_by_id(id)).to eq :id
    end
  end

  describe '#find_member_by_username(username)' do

    let( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow_any_instance_of(subject).to receive(:find_member_by_username).and_return :username
    end

    it "finds a member based on a username and returns a trello member object" do
      expect(connection).to receive(:find_member_by_username).with('username').and_return :username
      connection.find_member_by_username('username')
    end

    it "finds a member based on a username and returns a trello member object" do
      allow(connection).to receive(:find_member_by_username).with('username').and_return :username
      expect(connection.find_member_by_username('username')).to eq :username
    end
  end

  describe '#find_member_by_id' do

    let( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
      allow_any_instance_of(subject).to receive(:find_member_by_id).and_return :id
    end

    it "finds the right member based on the trello id and returns a trello member object" do
      id = 54
      expect(connection).to receive(:find_member_by_id).with(id).and_return :id
      connection.find_member_by_id(id)
    end

    it "finds the right member based on the trello id and returns a trello member object" do
      id = 54
      allow(connection).to receive(:find_member_by_id).with(id).and_return :id
      expect(connection.find_member_by_id(id)).to eq :id
    end
  end

  describe '#determine_reviewer' do

    let ( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "determines a valid || free reviewer" do
      card = stub_card_call
      allow(connection).to receive(:determine_reviewer).with(card, @members).and_call_original
      expect(connection.determine_reviewer(card, @members)).to eq :reviewer
    end

    it "determines a valid || free reviewer" do
      # member = OpenStruct.new(:name => 'boo', :id => 1)
      # member2 = OpenStruct.new(:name => 'art', :id => 2)
      # allow_any_instance_of(Trello::Card).to receive(:assignees).and_return [member]
      # card = OpenStruct.new(:assignees => [2])
      card = double('card')
      allow(card).to receive(:assignees).and_return([2])
      allow(connection).to receive(:team).and_return([1, 2])
      expect(connection.determine_reviewer(card)).to eq 1
    end
  end

  describe '#add_reviewer_to_card' do

    let ( :connection ) { subject.new }

    before do
      allow_any_instance_of(subject).to receive(:setup_trello).and_return true
    end

    it "" do

    end
  end
end




