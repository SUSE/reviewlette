require 'spec_helper'
require 'trello'
require 'octokit'



module Trello
  describe Card do
    include Helpers

    let(:card) { client.find(:card, 'abcdef123456789123456789') }
    let(:client) { Client.new }

    before(:each) do
      client.stub(:get).with("/cards/abcdef123456789123456789", {}).
          and_return JSON.generate(cards_details.first)
    end

    context "finding" do
      let(:client) { Trello.client }

      it "delegates to Trello.client#find" do
        client.should_receive(:find).with(:card, 'abcdef123456789123456789', {})
        Card.find('abcdef123456789123456789')
      end

      it "is equivalent to client#find" do
        Card.find('abcdef123456789123456789').should eq(card)
      end
    end


    context "updating" do
      it "updating name does a put on the correct resource with the correct value" do
        expected_new_name = "xxx"

        payload = {
            :name => expected_new_name,
        }

        client.should_receive(:put).once.with("/cards/abcdef123456789123456789", payload)

        card.name = expected_new_name
        card.save
      end
    end
    context "list" do
      it 'has a list' do
        client.stub(:get).with("/lists/abcdef123456789123456789", {}).and_return JSON.generate(lists_details.first)
        card.list.should_not be_nil
      end

      it 'can be moved to another list' do
        other_list = double(:id => '987654321987654321fedcba')
        payload = {:value => other_list.id}
        client.should_receive(:put).with("/cards/abcdef123456789123456789/idList", payload)
        card.move_to_list(other_list)
      end

      it 'should not be moved if new list is identical to old list' do
        other_list = double(:id => 'abcdef123456789123456789')
        payload = { :value => other_list.id }
        client.should_not_receive(:put)
        card.move_to_list(other_list)
      end

      it "should accept a string for moving a card to list" do
        payload = { value: "12345678"}
        client.should_receive(:put).with("/cards/abcdef123456789123456789/idList", payload)
        card.move_to_list("12345678")
      end
    end

    context "comments" do
      it "posts a comment" do
        client.should_receive(:post).
            with("/cards/abcdef123456789123456789/actions/comments", { :text => 'testing' }).
            and_return JSON.generate(boards_details.first)

        card.add_comment "testing"
      end
    end
  end
end

describe Octokit::Client::Issues do

  before do
    Octokit.reset!
    @client = oauth_client
  end
  describe ".list_issues"  do
    it "returns issues for a repository" do
      issues = stub_request(:get, "https://api.github.com/repos/jschmid1/reviewlette/issues")
      expect(issues).not_to a_kind_of Array
      assert_requested :get, 'https://api.github.com/repos/jschmid1/reviewlette/issues'
    end
  end
  describe ".add_comment" do
    it "adds a comment" do
      comment = stub_request(:post, "https://api.github.com/repos/jschmid1/reviewlette/issues/4/comments")
      expect(comment).to eql(:status => 200, :body => "", :headers => {})
    end
  end
end