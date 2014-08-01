require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'
require 'yaml'
require 'octokit'
require 'trello'

class Trello::Card

  def assignees
    @trello_connection = Reviewlette::TrelloConnection.new
    member_ids.map{|id| @trello_connection.find_member_by_id(id)}
  end
end

module Reviewlette

  attr_accessor :trello_connection, :github_connection, :repo, :board

  NAMES = YAML.load_file("#{File.dirname(__FILE__)}/../config/.members.yml")
  TRELLO_CONFIG1 = YAML.load_file("#{File.dirname(__FILE__)}/../config/.trello.yml")

  class << self


    def spin
      setup
      get_unassigned_github_issues.each do |a|
        @number = a[:number]
        @title = a[:title]
        @body = a[:body]
        @id = @trello_connection.find_card(@title.to_s)
        find_id
        if set_reviewer
          transform_name
          add_reviewer_on_github
          comment_on_github
          add_to_trello_card
          comment_on_trello
          move_to_list
          @reviewer = nil
        else
          @trello_connection.comment_on_card("Skipped Issue #{@card.short_id} because everyone on the team is assigned to the card", @card)
        end
      end
      puts 'No new issues.' unless @issues.present?
    end

    def get_unassigned_github_issues
      @issues = @github_connection.list_issues(@repo).select{|issue| !issue[:assignee]}
    end

    def setup
      @logger = Logger.new('review.log')
      @github_connection = Reviewlette::GithubConnection.new
      @trello_connection = Reviewlette::TrelloConnection.new
      @board = Trello::Board.find(TRELLO_CONFIG1['board_id'])
      @repo = Reviewlette::GithubConnection::GITHUB_CONFIG['repo']
    end

    # find_card_by_id returns TrelloCard instance
    def find_id
      if @id
        @card = @trello_connection.find_card_by_id(@id)
      else
        puts "id not found"
      end
    end

    def set_reviewer
      begin
        while !(@reviewer) # until
          @reviewer = @trello_connection.determine_reviewer(@card)
        end
        @trelloname = @reviewer.username
        puts "Selected #{@reviewer.username}"
        return true
      rescue AlreadyAssignedException => e
        @logger.warn("Skipped Issue #{@card.short_id} because #{e.message}")
        puts ("Skipped Issue #{@card.short_id} because #{e.message}")
        return false
      end
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
      @trello_connection.add_reviewer_to_card(@reviewer, @card)

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
