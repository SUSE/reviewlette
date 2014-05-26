require 'trello'
require 'yaml'
require 'debugger'

####### CONFIGURATION #############################################################
CONFIG = YAML.load_file('.trello.yml')
Trello.configure do |config|
  config.developer_public_key = CONFIG['consumerkey']
  config.member_token = CONFIG['oauthtoken']
end

####### INITS ##############
@board = Trello::Board.find(CONFIG['board_id'])



def add_to_card
  while (true) do
    # dont know how to catch
    # if reviewer is already on the card, catch error and try again with another sample (TODO)
    # loop over add card exit on success
    # save users in arrays and shift out
    user = CONFIG['member'].sample
    reviewer = @board.members.find{|m| m.username == user}
    if (reviewer)
      begin
        puts "trying to add user #{reviewer.username}"
        acard.add_member(reviewer)
        acard.add_comment("#{user}: i will review it")
        return
      rescue => error
        puts error.message
      end
    else
      puts "user #{user} not found in trello board"
    end
  end
end





