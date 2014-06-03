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
end
