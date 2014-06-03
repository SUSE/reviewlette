require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require 'yaml'
require 'octokit'
require 'trello'
require 'rdoc/rdoc'

TRELLO_CONFIG = YAML.load_file('.trello.yml')
GITHUB_CONFIG = YAML.load_file('.github.yml')
MEMBERS_CONFIG = YAML.load_file('home/jschmid/reviewlette/config/members.yml')
## Need to log in case of errors
#
# # Trello Card Manipulation
# class TrelloCard
#   # Finds a card due to naming convention
#   # Review_1337_name_of_pr_trello_shortid_454
#   def find_card(trelloid)
#     re1='.*?'	# Non-greedy match on filler
#     re2='\\d+'	# Uninteresting: int
#     re3='.*?'	# Non-greedy match on filler
#     re4='(\\d+)'	# Integer Number 1
#     re=(re1+re2+re3+re4)
#     m=Regexp.new(re,Regexp::IGNORECASE)
#     if m.match(trelloid)
#       @id=m.match(trelloid)[1]
#       puts "found card nr: #{@id}"
#       acard = @board.cards.find{|c| c.short_id == @id.to_i}
#     end
#     acard
#   end
#
#   # Finds member by id
#   def find_member_by_id(id)
#     @board.members.find{|m| m.id == id}
#   end
#
#   # Finds member by username
#   def find_member_by_username(username)
#     @board.members.find{|m| m.username == username}
#   end
#
#
#   # Adds a reviewer the trello card (found by (find_card))
#   def add_reviewer_to_card(card)
#     assignees = card.member_ids.map{|id| find_member_by_id(id)}
#     members = TRELLO_CONFIG['member'].map{|name| find_member_by_username(name) }
#     available_ids = members.map(&:id) - assignees.map(&:id)
#     reviewer = available_ids.map{|id| find_member_by_id(id)}.sample
#     # removes already assigned==owner of the card from the reviewers list
#     if reviewer
#       card.add_member(reviewer)
#       card.add_comment("#{reviewer.username} will review it")
#       puts "added #{reviewer} to the card"
#       return true
#     else
#       puts "No available reviewer found"
#     end
#     false
#   end
#
#   # Automatically moves the card to the right column.
#   def move_card_to_list(card, repo, number)
#     if (pull_merged?(repo, number))
#       # If reviewstatus is closed or merged move card to done
#       list_done= @board.lists.find {|x| x.name == 'Done'}
#       card.move_to_list(list_done.id)
#       puts "moved to #{list_done.name}"
#     else
#       ## if reviewstatus is open or merged move card to inReview
#       list_in_review = @board.lists.find {|x| x.name == 'in review'}
#       card.move_to_list(list_in_review.id)
#       puts "moved to #{list_in_review.name}"
#     end
#   end
# end


# Methods for the GitHub API
class Github < TrelloCard
  # initialize all the config stuff
  def init
    Trello.configure do |config|
      config.developer_public_key = TRELLO_CONFIG['consumerkey']
      config.member_token = TRELLO_CONFIG['oauthtoken']
    end
    @board = Trello::Board.find(TRELLO_CONFIG['board_id'])
    @mail = Supporter::Mailer.new
    @repo = 'jschmid1/reviewlette'
    @client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
    @client.user_authenticated? ? true : exit
    assignee?(@repo)
  end

  # List issues. If noone is assigned, consider it as a new issue.
  def assignee?(repo)
    status = @client.list_issues("#{repo}")
    status.each do |a|
      unless a[:assignee]
        @number = a[:number]
        @title = a[:title]
        @body = a[:body]
        card = find_card(@title)
        # Only proceed when a card was found
        if card
          add_assignee(@number, @title, @body)
          move_card_to_list(card, @repo, @number) if add_reviewer_to_card(card)
        else
          puts "Card not found for title #{@title.inspect}"
        end
      end
    end
  end

  # Checks if the pull is merged
  def pull_merged?(repo, number)
    #check if pull is merged
    @client.pull_merged?(repo, number)
  end


  # Adds an assignee to an Github-issue
  def add_assignee(number, title, body)
    # Error in here. Not the same name as in Trello.
    @client.update_issue("#{@repo}", "#{number}", "#{title}", "#{body}",{:assignee => "#{name}"})
    @client.add_comment("#{@repo}", "#{number}", "#{name} is your reviewer :thumbsup: ")
    # @mail.send_email "#{user => email}", :body => "#{somegenerated text with a link to the review}"
    # check yaml doc for hashes in order to store the name => email
  end
end

start = Github.new
start.init

def die_pls
  return "die pls"
end
