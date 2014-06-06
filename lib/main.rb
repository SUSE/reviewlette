require 'rubygems'
require 'debugger'
require '/home/jschmid/reviewlette/mail'
require 'yaml'
require 'octokit'
require 'trello'
require 'rdoc/rdoc'

TRELLO_CONFIG = YAML.load_file('.trello.yml')
GITHUB_CONFIG = YAML.load_file('.github.yml')
MEMBERS_CONFIG = YAML.load_file('home/jschmid/reviewlette/config/members.yml')
