require 'yaml'
require 'debugger'
require 'trello'

class Trello::Card

  def assignees
    @trello_connection = ::Reviewlette::TrelloConnection.new
    member_ids.map{|id| @trello_connection.find_member_by_id(id)}
  end
end

module Reviewlette

  class TrelloConnection

    attr_accessor :board

    def initialize
      setup_trello
    end

    def find_card(title)
      re1='.*?'
      re2='\\d+'
      re3='.*?'
      re4='(\\d+)'
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE)
      if m.match(title)
        id=m.match(title)[1]
        puts "Found card : #{id}"
        @id = m.match(title)[1]
      else
        nil
      end
    end

    def determine_reviewer(card)
      raise "Everyone on the team is assigned to the Card." if reviewer_exception_handler(card)
      find_member_by_username(sample_reviewer(card))
    end

    def sample_reviewer(card)
      (team - card.assignees.map(&:username)).sample
    end

    def reviewer_exception_handler(card)
      (team - card.assignees.map(&:username)).count <= 0
    end

    def add_reviewer_to_card(reviewer, card)
      card.add_member(reviewer) if reviewer
    end

    def comment_on_card(reviewer, card)
      card.add_comment(reviewer) if reviewer
    end

    def move_card_to_list(card, column)
      card.move_to_list(column)
    end

    def team
      @team ||= NAMES.keys
    end

    def find_column(column_name)
      @board.lists.find {|x| x.name == column_name}
    end

    def find_member_by_username(username)
      @board.members.find{|m| m.username == username}
    end

    def find_member_by_id(id)
      @board.members.find{|m| m.id == id}
    end

    def find_card_by_id(id)
      @board.cards.find{|c| c.short_id == id.to_i}
    end

    def setup_trello
      Trello.configure do |config|
        config.developer_public_key = ::Reviewlette::TRELLO_CONFIG1['consumerkey']
        config.member_token = ::Reviewlette::TRELLO_CONFIG1['oauthtoken']
      end
      @board = Trello::Board.find(::Reviewlette::TRELLO_CONFIG1['board_id'])
    end
  end
end
