$:.unshift(File.expand_path(File.dirname(__FILE__))) unless
$:.include?(File.dirname(__FILE__)) || $:.include?(File.expand_path(File.dirname(__FILE__)))
require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'
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

    NAMES = YAML.load_file('../config/.members.yml')
    TRELLO_CONFIG1 = YAML.load_file('../config/.trello.yml')


    def spin
      setup
      @github_connection.list_issues(@repo).each do |a|
        unless a[:assignee]
          @number = a[:number]
          @title = a[:title]
          @body = a[:body]
          @id = @trello_connection.find_card(@title.to_s)
          find_id
          set_reviewer
          transform_name
          add_reviewer_on_github
          comment_on_github
          add_to_trello_card
          comment_on_trello
          move_to_list
          @reviewer = nil
        end
      end
      abort 'No new issues.'
    end

    def setup
      @github_connection = Reviewlette::GithubConnection.new
      @trello_connection = Reviewlette::TrelloConnection.new
      @board = Trello::Board.find(TRELLO_CONFIG1['board_id'])
      @repo = 'jschmid1/reviewlette'
    end


    def find_id
      if @id
        @card = @trello_connection.find_card_by_id(@id)
      else
        abort "id not found"
      end
    end

    def set_reviewer
      while !(@reviewer)
        @reviewer = @trello_connection.determine_reviewer(@card)
      end
      @trelloname = @reviewer.username
      puts "Chose: #{@reviewer.username}"
    end

    def transform_name
      @githubname = NAMES[@trelloname]
    end

    def add_reviewer_on_github
      @github_connection.add_assignee(@number, @title, @body, @githubname) if @number && @githubname
    end

    def comment_on_github
      @github_connection.comment_on_issue(@number, @githubname, @card.url) if @number && @githubname
    end

    def add_to_trello_card
      begin
        @trello_connection.add_reviewer_to_card(@reviewer, @card)
      rescue
        puts 'already assigned'
      end
    end

    def comment_on_trello
      @full_comment = '@' + @trelloname + ' will review ' + 'https://github.com/'+ @repo+'/issues/'+@number.to_s
      @trello_connection.comment_on_card(@full_comment, @card) if @full_comment
    end

    def move_to_list
      if @github_connection.pull_merged?(@repo, @id)
        @column = @trello_connection.find_column('Done')
        @trello_connection.move_card_to_list(@card, @column)
      else
        @column = @trello_connection.find_column('In review')
        @trello_connection.move_card_to_list(@card, @column)
      end
    end
  end
end
