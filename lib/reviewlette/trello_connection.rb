require 'yaml'
require 'trello'

class TrelloConnection

  attr_accessor :board

  def initialize
    @trello = YAML.load_file("#{File.dirname(__FILE__)}/../../config/trello.yml")
    Trello.configure do |config|
      config.developer_public_key = @trello['consumerkey']
      config.member_token = @trello['oauthtoken']
    end
    @board = Trello::Board.find(@trello['board_id'])
  end

  def add_reviewer_to_card(reviewer, card)
    reviewer = find_member_by_username(reviewer)
    card.add_member(reviewer)
  end

  def comment_reviewers(card, repo_name, issue_id, reviewers)
    comment = reviewers.map { |r| "@#{r['trello_username']}" }.join(' and ')
    comment += " will review https://github.com/#{repo_name}/issues/#{issue_id}"
    card.add_comment(comment)
  end

  def move_card_to_list(card, column_name)
    column = find_column(column_name)
    card.move_to_list(column)
  end

  def find_column(column_name)
    @board.lists.find { |x| x.name == column_name }
  end

  def find_member_by_username(username)
    @board.members.find { |m| m.username == username }
  end

  def find_card_by_id(id)
    @board.cards.find { |c| c.short_id == id.to_i }
  end
end
