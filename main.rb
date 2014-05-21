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
#



secrets = YAML.load_file '.secrets.yml'
client = Octokit::Client.new access_token: secrets['token']

puts client.repos('jschmid1').first.inspect
# puts client.repo(17440018)






















