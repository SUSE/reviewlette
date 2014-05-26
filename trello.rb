require 'trello'
require 'yaml'
require 'debugger'


####### CONFIGURATION #############################################################
CONFIG = YAML.load_file('.trellokey.yml')
Trello.configure do |config|
  config.developer_public_key = CONFIG['consumerkey']
  config.member_token = CONFIG['oauthtoken']
end
me =Trello::Member.find(CONFIG['member'].first)
###################################################################################

####### INITS ##############
board = Trello::Board.find(CONFIG['board_id'])
# gitcard = board.cards.find{|c| c.name == provided_by_reviewname}
## find the card based on pull-request id (TODO) # convention pls
acard = Trello::Card.find('71qhMG11')
## work with fake card and fake board
## randomly choose a reviewer

## choosing the right card


## have to use a hardcoded list because too many ppl in the board

@member=[]
# reviewer.each do |u|
#   @member.push(u.username)
# end
debugger
###################################################################################
while (true) do
  #save users in arrays and shift out
  user = CONFIG['member'].sample
  reviewer = board.members.find{|m| m.username == user}
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
## dont know how to catch
## if reviewer is already on the card, catch error and try again with another sample (TODO)
##loop over add card exit on success

list_inreview = board.lists.find {|x| x.name == 'in review'}
list_done= board.lists.find {|x| x.name == 'Done'}
## if reviewstatus is 'closed or merged? == true' move card to done
(@client.pull_merged?(@repo, @pull_list[-1])) ? acard.move_to_list(list_done) : acard.move_to_list(list_inreview)

## if reviewstatus is 'open or merged? == false' move card to inReview


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
