require '/home/jschmid/reviewlette/lib/reviewlette/trello_connection'
require '/home/jschmid/reviewlette/lib/reviewlette/github_connection'
require 'yaml'
require 'octokit'
require 'trello'
require 'debugger'



class Trello::Card

  def assignees
    @trello_connection = Reviewlette::TrelloConnection.new
    member_ids.map{|id| @trello_connection.find_member_by_id(id)}
  end
end


module Reviewlette

  attr_accessor :trello_connection, :github_connection

  class << self
    TRELLO_CONFIG1 = YAML.load_file('/home/jschmid/reviewlette/config/.trello.yml')
    def spin!
      @github_connection = Reviewlette::GithubConnection.new
      puts "gh con established"
      @trello_connection = Reviewlette::TrelloConnection.new
      puts "tr con established"
      @board = Trello::Board.find(TRELLO_CONFIG1['board_id'])
      @repo = 'jschmid1/reviewlette'
      @team ||= TRELLO_CONFIG1['member'].map{|name| @trello_connection.find_member_by_username(name) }
    end

    def main
      Reviewlette.spin!
      @github_connection.list_issues(@repo).each do |a|
        unless a[:assignee]
          @number = a[:number]
          @title = a[:title]
          @body = a[:body]
          @id = @trello_connection.find_card(@title.to_s)
          @card = @trello_connection.find_card_by_id(@id)
          @reviewer = @trello_connection.determine_reviewer(@card)
          # catch errors
          @trelloname = @reviewer.username
          @githubname = name_converter(@trelloname)
          @github_connection.add_assignee(@number, @title, @body, @githubname)
          debugger
          # @github_connection.comment_on_issue(@repo, @id, @githubname)
          @trello_connection.add_reviewer_to_card(@reviewer, @card)
          # rescue if is already on card
          @trello_connection.comment_on_card(@trelloname, @card)
          if @github_connection.pull_merged?(@repo, @id)
            @column = @trello_connection.find_column('Done')
            @trello_connection.move_card_to_list(@card, @column)
          else
            @column = @trello_connection.find_column('in-review')
            @trello_connection.move_card_to_list(@card, @column)
          end
        end
      end
    end

    def name_converter(name)
      if name == 'jschmid'
        @name = 'jschmid1'
      elsif name == 'thomasschmidt'
        @name = 'digitaltom'
      elsif name == 'artemchernikov'
        @name = 'kalabiyau'
      end
    end


  end
end

Reviewlette.main




# 1. establish connection
# 2. check assignee
# 3. add assignee
# 4. find card
# 5. add comment and reviewer
# 6. list the card
#