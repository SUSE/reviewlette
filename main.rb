require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require 'yaml'
require 'octokit'
require 'trello'


####### CONFIGURATION #############################################################
TRELLO_CONFIG = YAML.load_file('.trello.yml')
Trello.configure do |config|
  config.developer_public_key = TRELLO_CONFIG['consumerkey']
  config.member_token = TRELLO_CONFIG['oauthtoken']
end
@board = Trello::Board.find(TRELLO_CONFIG['board_id'])
MEMBERS = YAML.load_file('members.yml')
@mail = Supporter::Mailer.new

@repo = 'jschmid1/reviewlette'
GITHUB_CONFIG = YAML.load_file('.github.yml')
@client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
@client.user_authenticated? ? true : exit



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
    acard = @board.cards.find{|c| c.short_id == @id.to_i}
  end
  acard
end



def find_member_by_id(id)
  @board.members.find{|m| m.id == id}
end



def find_member_by_username(username)
  @board.members.find{|m| m.username == username}
end



def add_reviewer_to_card(card)
  assignees = card.member_ids.map{|id| find_member_by_id(id)}
  members = TRELLO_CONFIG['member'].map{|name| find_member_by_username(name) }
  available_ids = members.map(&:id) - assignees.map(&:id)
  reviewer = available_ids.map{|id| find_member_by_id(id)}.sample
  if reviewer
    card.add_member(reviewer)
    card.add_comment("#{reviewer.username} will review it")
    return true
  else
    puts "No available reviewer found"
  end
  false
end


def move_card_to_list(card, repo, number)
  ## if reviewstatus is 'open or merged? == false' move card to inReview
  # if reviewstatus is 'closed or merged? == true' move card to done

  if (pull_merged?(repo, number))
    list_done= @board.lists.find {|x| x.name == 'Done'}
    card.move_to_list(list_done.id)
    puts "moved to #{list_done.name}"
  else
    list_in_review = @board.lists.find {|x| x.name == 'in review'}
    card.move_to_list(list_in_review.id)
    puts "moved to #{list_in_review.name}"
  end
end


def assignee?(repo)
  # list issues. if noone is assigned, consider it as a new issue and continue
  status = @client.list_issues("#{repo}")
  status.each do |a|
    unless a[:assignee]
      @number = a[:number]
      @title = a[:title]
      @body = a[:body]

      card = find_card(@title)

      if card
        # add_assignee(@number, @title, @body)
        move_card_to_list(card, @repo, @number) if add_reviewer_to_card(card)
      else
        puts "Card not found for title #{@title.inspect}"
      end
    end
  end
end


def pull_merged?(repo, number)
  @client.pull_merged?(repo, number)
end


def add_assignee(number, title, body)
  # adds assignee, posts comment and sends mail
  name = MEMBERS['member'].sample
  # check if a assignee is set? catch error (TODO)
  @client.update_issue("#{@repo}", "#{number}", "#{title}", "#{body}",{:assignee => "#{name}"})
  @client.add_comment("#{@repo}", "#{number}", "#{name} is your reviewer :thumbsup: ")
  # @mail.send_email "#{user => email}", :body => "#{somegenerated text with a link to the review}"
  # check yaml doc for hashes in order to store the name => email
end


assignee?(@repo)
















