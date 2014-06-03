require 'spec_helper'
require 'trello_card'


describe TrelloCard do
  describe "#find_card" do
    it "conforms to the card id with specific structure" do
      expect(described_class.find_card("Asd")).to be nil
    end
    it "conforms to the card id with specific structure" do
      line = "Review_1337_name_of_pr_trello_shortid_454"
      expect(described_class).to receive(:find_card_by_id).with('454').and_return :asd
      expect(described_class.find_card(line)).to eq :asd
    end
    it "conforms to the card id with specific structure" do
      line = "Review_1337_name_of_pr_trello_shortid_454"
      expect(described_class).to receive(:find_card_by_id).with('454').and_return :asd
      described_class.find_card(line)
    end
  end
  describe "#add_reviewer_to_card" do
    it "should collect all card members " do
      card = double('trellocard')
      expect(described_class).to receive_message_chain(:member_ids, :map).and_return :bla

    end
  end
end