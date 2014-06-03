module Reviewlette

  class TrelloConnection

    TRELLO_CONFIG = YAML.load_file('.trello.yml')

    attr_accessor :board

    def initialize
      setup_trello
    end

    def find_card(trelloid)
      re1='.*?'	# Non-greedy match on filler
      re2='\\d+'	# Uninteresting: int
      re3='.*?'	# Non-greedy match on filler
      re4='(\\d+)'	# Integer Number 1
      re=(re1+re2+re3+re4)
      m=Regexp.new(re,Regexp::IGNORECASE)
      if m.match(trelloid)
        @id=m.match(trelloid)[1]
        puts "found card nr: #{@id}"
        find_card_by_id(@id)
      else
        nil
      end
    end


    private

    def find_card_by_id(id)
      @board.cards.find{|c| c.short_id == id.to_i}
    end

    def setup_trello


      Trello.configure do |config|
        config.developer_public_key = TRELLO_CONFIG['consumerkey']
        config.member_token = TRELLO_CONFIG['oauthtoken']
      end

      @board = Trello::Board.find(TRELLO_CONFIG['board_id'])
    end

  end

end
