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
  let(:board) { stub_boards_call }
  let(:repo) { 'repo/repo' }
  let(:id) { 23 }
  let(:card) { stub_card_call }
  let(:trello_connection) { double 'trello_connection' }
  let(:reviewer) {double 'reviewer'}
  let(:github_connection) { double 'github_connection' }

  describe '.transform_name' do
    it 'transforms trelloname to github name' do
      Reviewlette.instance_variable_set("@trelloname", 'jschmid')
      Reviewlette.transform_name
      expect(Reviewlette.instance_variable_get("@githubname")).to be_a_kind_of String
      #good
    end
  end

  describe '.find_id' do
    it 'finds the id' do
      instance_variable! :id
      instance_variable! :trello_connection
      expect(trello_connection).to receive(:find_card_by_id).with(id).and_return card
      Reviewlette.find_id
    end

    it 'does not find the id' do
      Reviewlette.instance_variable_set("@id", '')
      instance_variable! :trello_connection
      expect(trello_connection).to receive(:find_card_by_id).with('').and_return 'id not found'
      Reviewlette.find_id
    end
  end

  describe '.set_reviewer' do
    it 'sets the reviewer' do
      instance_variable! :trello_connection
      instance_variable! :card
      expect(trello_connection).to receive(:determine_reviewer).with(card).and_return reviewer
      expect(reviewer).to receive(:username).and_return String
      Reviewlette.set_reviewer
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
  end
end

