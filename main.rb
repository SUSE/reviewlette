require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require '/home/jschmid/reviewlette/auth'
require '/home/jschmid/reviewlette/nameparser'
require 'yaml'
require 'octokit'

# user = Auth::Basic.new
# user.basic_auth
#
# pars = Parse::Contributers.new
# pars.get_names
#
# #puts $array #debug maybe store it into a file later on
# name =  $name_list.sample
#
# mail = Supporter::Mailer.new
# mail.send_email "jschmid@suse.de", :body => "#{name}"

secret = YAML.load_file('.secrets.yml')
@client = Octokit::Client.new(:access_token => secret['token'])
@client.user_authenticated? ? true : exit




@eval= @client.pull_requests('jschmid1/reviewlette')
@pull_list_old = []
@pull_list = []
@eval.each do |a|
  number = a[:number]
  @pull_list_old.push(number)
  if @pull_list_old.push(number).length < @pull_list.push(number).length
    sha = @client.pull_request('jschmid1/reviewlette', "#{@pull_list[-1]}" )
    @sha_id= sha.head.sha
    name = YAML.load_file('members.yml')
    @client.create_pull_request_comment('jschmid1/reviewlette', "#{@pull_list[-1]}", "#{name['member'].sample} is you reviewer", "#{@sha_id}", '/', 1)
  end
end





# client.user.rels[:repos].get.data.first.rels[:pulls].get.data.inspect


# @client.create_pull_request('jschmid1/reviewlette', 'master', 'review_140521_test_branch', 'title', 'body')


# @client.update_pull_request('jschmid1/reviewlette', 5, 'new title', 'updated body', 'closed')



# @client.create_pull_request_comment('jschmid1/reviewlette', 5, ":thumbsup:",
#                                     '259b7293f03f13e71cdf7825eda2c5da8b67c59d', 'README.md', 1)

# puts @client.say
#
# count pullrequests => if pullrequests.new > pullrequests
#                         assign teammember to it
#                         create pull request comment
#                         send mail
#                       end

# will be depricated when implemented in git-review gem



# @user = @client.search_users('jschmid1').inspect


#no mehtod for asssining a teammember to a given issue