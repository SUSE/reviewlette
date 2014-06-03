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

end
