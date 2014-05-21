require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require '/home/jschmid/reviewlette/auth'
require '/home/jschmid/reviewlette/nameparser'
require 'yaml'

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

client = Octokit.Client.new (:access_token => secret[:token] )

puts client.inspect


























