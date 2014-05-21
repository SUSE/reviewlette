require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require '/home/jschmid/reviewlette/auth'
require '/home/jschmid/reviewlette/nameparser'


user = Auth::Basic.new
user.basic_auth

pars = Parse::Contributers.new
pars.get_names


puts @@array #debug maybe store it into a file later on
## bug ! fix tomorrow
name =  @@array[0]


mail = Supporter::Mailer.new
mail.send_email "jschmid@suse.de", :body => "#{name}"


























