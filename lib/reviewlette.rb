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

    # Execute logic.
    def spin
      setup
      get_unassigned_github_issues.each do |a|
        @number = a[:number]
        @title = a[:title]
        @body = a[:body]
        find_card(@title.to_s)
        if find_id
          if set_reviewer
            transform_name
            add_reviewer_on_github
            comment_on_github
            add_to_trello_card
            comment_on_trello
            move_to_list
            @reviewer = nil
          else
            comment_on_error
          end
        end
        puts 'No new issues.' unless @issues.present?
      end
    end

    # Finds card based on title of Github Issue.
    # Or by branch name if title does not include the trello number.
    # Happens if the pullrequest consists of only one commit.
    def find_card(title)
      begin
        match_pr_id_with_issue_id
        @id = title.split('_').last.to_i
        @id = fetch_branch if @id == 0 && !(@pullreq_ids.values.index(@number)).nil?
        raise NoTrelloCardException, "Could not find a Trello card. Found #{title.split('_').last} instead, maybe the naming of your pullrequest is wrong? And/or you dont have a branch?" if @id == 0
        true
      rescue NoTrelloCardException => e
        puts (e.message)
        false
      end
    end

    # gets the branchname from github pullrequest
    def fetch_branch
      pr_id = @pullreq_ids.values.index(@number)
      branch_name = @github_connection.get_branch_name(pr_id, @repo)
      branch_name.split('_').last.to_i
    end

    # Matches Pull Request IDs with the respective Order of PullRequests
    # to call them and get the branch name.
    def match_pr_id_with_issue_id
      @pullreq_ids = {}
      @counter = 0
      @github_connection.list_pulls(@repo).each do |x|
        @pullreq_ids[@counter] = x.number
        @counter +=1
      end
    end

    # TODO: Generic Error message.
    def comment_on_error
      @trello_connection.comment_on_card("Skipped Issue #{@number} because everyone on the team is assigned to the card", @card)
    end

    # Gets [Array(String, String)] all GitHub Issues that are not assigned to someone.
    def get_unassigned_github_issues
      @issues = @github_connection.list_issues(@repo).select{|issue| !issue[:assignee]}
    end

    # Sets instance variables.
    def setup
      @logger = Logger.new('review.log')
      @github_connection = Reviewlette::GithubConnection.new
      @trello_connection = Reviewlette::TrelloConnection.new
      @board = Trello::Board.find(TRELLO_CONFIG1['board_id'])
      @repo = Reviewlette::GithubConnection::GITHUB_CONFIG['repo']
    end

    # Finds a sets card.
    def find_id
      if @id != 0
        @card = @trello_connection.find_card_by_id(@id)
        true
      else
        @logger.warn("Id not found, skipping Issue #{@title} with number #{@number}")
        false
      end
    end

    # Selects and sets reviewer.
    def set_reviewer
      begin
        while !(@reviewer)
          @reviewer = @trello_connection.determine_reviewer(@card) if @card
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

    # Get Trelloname from configfile.
    def transform_name
      @githubname = NAMES[@trelloname]
    end

    # Adds Assignee on GitHub.
    def add_reviewer_on_github
      @github_connection.add_assignee(@number, @title, @body, @githubname) if @number && @githubname
    end

    # Comments on GitHub.
    def comment_on_github
      @github_connection.comment_on_issue(@number, @githubname, @card.url) if @number && @githubname
    end
    # Adds Reviewer on Trello Card.
    def add_to_trello_card
      @trello_connection.add_reviewer_to_card(@reviewer, @card)
    end

    # Comments on Trello Card.
    def comment_on_trello
      @full_comment = '@' + @trelloname + ' will review ' + 'https://github.com/'+ @repo+'/issues/'+@number.to_s
      @trello_connection.comment_on_card(@full_comment, @card) if @full_comment
    end

    # TODO: More generic 'Done' and 'in Review' are not present everywhere
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
