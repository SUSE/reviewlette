require 'trello'
require 'yaml'
require 'debugger'

####### CONFIGURATION #############################################################
CONFIG = YAML.load_file('.trellokey.yml')
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







#### STRATEGY #####
=begin

A pull request is created
=> track it
Assign a teammember to it
=> assign gh api
=> move_to list('review')
=> send notification mail
Find the Trello Card and Post a comment
=> comment trello api
=> add_member trello api
If the pullrequest is closed
=> gh api closed?
move the card to Done
=> move_to_list('done')
=> send notification mail


=end

# puts "Members: #{board.members.map {|x| x.full_name}.join(', ')}"
# puts "Lists: #{board.lists.map {|x| x.name}.join(', ')}"
# board.cards.each do |card|
#   puts "- \"#{card.name}\""
#   puts "-- Actions: #{card.actions.nil? ? 0 : card.actions.count}"
#   puts "-- Members: #{card.members.count}"
#   puts "-- Labels: #{card.labels.count}"
# end

# acard.members.each do |a|
#
#   @fullname = a.full_name
#   @username = a.id
#   puts @username
#
# end
