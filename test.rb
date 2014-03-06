#!/usr/bin/env ruby
require 'yaml'

class Reviewlette
  attr_accessor :name
  attr_accessor :activity
  def namereturn
    'jschmid'
  end
  def readfromfile
    config = YAML.load_file("names.yml")
    @allnames = config
    @name = @allnames.sample
    
  end 
  def activitystodo
    bconfig = YAML.load_file("activitys.yml")
    @allactivity = bconfig
    @activity = @allactivity.sample
  end
  def namecall
  readfromfile unless @name
   puts "its your turn #{@name}"
   puts "do you have time for this? #{@name}" 
   puts "Yes or No. Type in y or n"
  end
  def askuser
   response = gets 
   response = response.chomp
   if response == "y" then
   puts "Well then #{@activity}"
   else
   puts "Oke bring me someone else"
   end 
  end
end

roulette= Reviewlette.new
roulette.activitystodo
roulette.namecall
roulette.askuser


#do the yml file handling with an api -> next step 
#see git-review 
	


