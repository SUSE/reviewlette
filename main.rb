require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require '/home/jschmid/reviewlette/auth'
require '/home/jschmid/reviewlette/nameparser'
require 'yaml'
require 'octokit'

MEMBERS = YAML.load_file('members.yml')
# mail = Supporter::Mailer.new

@repo = 'jschmid1/reviewlette'

secret = YAML.load_file('.secrets.yml')
@client = Octokit::Client.new(:access_token => secret['token'])
@client.user_authenticated? ? true : exit



def assignee?(repo)
  # list issues. if noone is assigned consider it as a new issue and continue
  status = @client.list_issues("#{repo}")
  status.each do |a|
    if !(a[:assignee])
      @number = a[:number]
      @title = a[:title]
      @body = a[:body]
      add_assignee(@number, @title, @body)
    end
  end
end

# @client.update_issue("#{@repo}", "#{@number}", "#{@title}", nil,{:assignee => 'jschmid1'})




def add_assignee(number, title, body)
  #adds assignee, posts comment and sends mail
  name = MEMBERS['member'].sample


  @client.add_comment("#{@repo}", "#{number}", "#{name} is your reviewer")
  #check if a assignee is set? catch error
  @client.update_issue("#{@repo}", "#{number}", "#{title}", "#{body}",{:assignee => 'jschmid1'})
  #find participants ( or edit the names file to github names => value=githubname)
  # mail.send_email "#{notimplementedyet}", :body => "#{somegenerated text with a link to the review}"
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