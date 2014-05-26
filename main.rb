require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require '/home/jschmid/reviewlette/auth'
require '/home/jschmid/reviewlette/nameparser'
require 'yaml'
require 'octokit'


# mail = Supporter::Mailer.new
# mail.send_email "jschmid@suse.de", :body => "#{name}"
repo = 'jschmid1/reviewlette'

secret = YAML.load_file('.secrets.yml')
@client = Octokit::Client.new(:access_token => secret['token'])
@client.user_authenticated? ? true : exit

def assignee?(repo)
  # list issues. if noone is assigned consider it as a new issue and continue

  status = @client.list_issues("#{repo}")
  status.each do |a|
    if !(a[:assignee]) == ''
      eval= @client.pull_requests("#{repo}")
      @pull_list = []
      eval.each do |x|
        number = x[:number]
        @pull_list.push(number)
      end
      add_assignee(@pull_list[-1])
    end
  end
end


debugger
def add_assignee(number)
  #adds assignee, posts comment and sends mail

  name = YAML.load_file('members.yml')
  # need this to comment on specific files
  # sha = @client.pull_request("#{@repo}", "#{number}" )
  # sha_id= sha.head.sha
  # @client.pull_request_files("#{repo}, #{number}")

  @client.add_comment("#{@repo}", "#{number}", "#{name} is your reviewer")
  @client.update_issue("#{@repo}", "#{number}", 'title', nil,{:assignee => "#{name}"})
  #find participants ( or edit the names file to github names => value=githubname)
  # mail.send_email "#{notimplementedyet}", :body => "#{somegenerated text with a link to the review}"
end




# @client.create_pull_request('jschmid1/reviewlette', 'master', 'review_140521_test_branch', 'title', 'body')
# - (Array<Sawyer::Resource>) pull_request_files(repo, number, options = {}) (also: #pull_files)
#
#     List files on a pull request.

# @user = @client.search_users('jschmid1').inspect

assignee?(repo)