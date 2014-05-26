require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require 'yaml'
require 'octokit'
require 'trello'


####### CONFIGURATION #############################################################
TRELLO_CONFIG = YAML.load_file('.trellokey.yml')
Trello.configure do |config|
  config.developer_public_key = TRELLO_CONFIG['consumerkey']
  config.member_token = TRELLO_CONFIG['oauthtoken']
end
@board = Trello::Board.find(TRELLO_CONFIG['board_id'])
MEMBERS = YAML.load_file('members.yml')
@mail = Supporter::Mailer.new
@repo = 'jschmid1/reviewlette'
GITHUB_CONFIG = YAML.load_file('.secrets.yml')
@client = Octokit::Client.new(:access_token => GITHUB_CONFIG['token'])
@client.user_authenticated? ? true : exit



# @acard = Trello::Card.find('OpyYLJkQ')
def find_card(title)
  title='git_review_123123123_trello: 23'
  re1='.*?'	# Non-greedy match on filler
  re2='\\d+'	# Uninteresting: int
  re3='.*?'	# Non-greedy match on filler
  re4='(\\d+)'	# Integer Number 1
  re=(re1+re2+re3+re4)
  m=Regexp.new(re,Regexp::IGNORECASE)
  if m.match(txt)
    @id=m.match(title)[1]
    puts @id
  end
  @acard = @board.cards.find{|c| c.short_id == @id}
  debugger
end


def add_to_card
  # need some logic to not assign an already assigned member to the card
  # still broken
  user = TRELLO_CONFIG['member'].sample
  reviewer = @board.members.find{|m| m.username == user}
  puts "trying to add user #{reviewer.username}"
  @acard.add_member(reviewer)
  @acard.add_comment("#{user}: i will review it")
end


def move_list(repo, number)
  ## if reviewstatus is 'open or merged? == false' move card to inReview
  # if reviewstatus is 'closed or merged? == true' move card to done
  list_in_review = @board.lists.find {|x| x.name == 'in review'}
  list_done= @board.lists.find {|x| x.name == 'Done'}
  if (@client.pull_merged?(repo, number))
    @acard.move_to_list(list_done.id)
    puts "moved to #{list_done.name}"
  else
    @acard.move_to_list(list_in_review.id)
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
      # add_assignee(@number, @title, @body)
      # move_list(@repo, @number)
      find_card(@title)
    end
  end
end



def add_assignee(number, title, body)
  # adds assignee, posts comment and sends mail
  name = MEMBERS['member'].sample
  debugger
  # check if a assignee is set? catch error (TODO)
  @client.update_issue("#{@repo}", "#{number}", "#{title}", "#{body}",{:assignee => "#{name}"})
  @client.add_comment("#{@repo}", "#{number}", "#{name} is your reviewer :thumbsup: ")
  # @mail.send_email "#{user => email}", :body => "#{somegenerated text with a link to the review}"
end


assignee?(@repo)
















# @client.create_pull_request('jschmid1/reviewlette', 'master', 'review_140521_test_branch', 'title', 'body')
# - (Array<Sawyer::Resource>) pull_request_files(repo, number, options = {}) (also: #pull_files)
#
#     List files on a pull request.

# @user = @client.search_users('jschmid1').inspect

# need this to comment on specific files
# sha = @client.pull_request("#{@repo}", "#{number}" )
# sha_id= sha.head.sha
# @client.pull_request_files("#{repo}, #{number}")