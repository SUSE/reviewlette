#!/usr/bin/env ruby
require 'yaml'

class Reviewlette
  attr_accessor :name
  def namereturn
    'jschmid'
  end
  def readfromfile
    config = YAML.load_file("names.yml")
    @allnames = config
    @name = @allnames.sample
  end
  def namecall
  readfromfile unless @name
   "its your turn #{@name}"
  end
end

roulette= Reviewlette.new
roulette.readfromfile
puts roulette.namecall



#do the yml file handling with an api -> next step 
#see git-review 
	


