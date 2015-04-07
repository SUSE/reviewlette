require 'yaml'
require 'trello'

TRELLO_CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../../config/trello.yml")

class TrelloConnection

  attr_accessor :board

  def initialize
    Trello.configure do |config|
      config.developer_public_key = TRELLO_CONFIG['consumerkey']
      config.member_token = TRELLO_CONFIG['oauthtoken']
    end
    @board = Trello::Board.find(TRELLO_CONFIG['board_id'])
  end

  def add_reviewer_to_card(reviewer, card)
    reviewer = find_member_by_username(reviewer)
    card.add_member(reviewer)
  end

  def comment_on_card(comment, card)
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

