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
@repo = 'jschmid1/reviewlette'

secret = YAML.load_file('.secrets.yml')
@client = Octokit::Client.new(:access_token => secret['token'])
@client.user_authenticated? ? true : exit




@eval= @client.pull_requests("#{@repo}")
@pull_list_old = []
@pull_list = []
@eval.each do |a|
  number = a[:number]
  @pull_list_old.push(number)
  sleep(10)
  if @pull_list_old.length < @pull_list.push(number).length
    sha = @client.pull_request("#{@repo}", "#{@pull_list[-1]}" )
    @sha_id= sha.head.sha
    name = YAML.load_file('members.yml')
    @client.create_pull_request_comment("#{@repo}", "#{@pull_list[-1]}",
                                        "#{name['member'].sample} is you reviewer :thumbsup:", "#{@sha_id}", '', 1)
    mail.send_email "#{notimplementedyet}", :body => "#{somegenerated text with a link to the review}"
  end
end





# @client.create_pull_request('jschmid1/reviewlette', 'master', 'review_140521_test_branch', 'title', 'body')
# - (Array<Sawyer::Resource>) pull_request_files(repo, number, options = {}) (also: #pull_files)
#
#     List files on a pull request.

# @user = @client.search_users('jschmid1').inspect

#no mehtod for asssining a teammember to a given issue