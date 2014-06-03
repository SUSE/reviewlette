module Reviewlette

  class TrelloConnection
    TRELLO_CONFIG = YAML.load_file('.trello.yml')

    attr_accessor :board

    def initialize

      Trello.configure do |config|
        config.developer_public_key = TRELLO_CONFIG['consumerkey']
        config.member_token = TRELLO_CONFIG['oauthtoken']
      end

      @board = Trello::Board.find(TRELLO_CONFIG['board_id'])

    end
  end

end
