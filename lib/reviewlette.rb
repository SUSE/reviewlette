require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'
require 'reviewlette/vacations'
require 'yaml'

VERSION = '0.0.6'
MEMBERS_CONFIG = YAML.load_file("#{File.dirname(__FILE__)}/../config/members.yml")

class Reviewlette

  def initialize
    @github = GithubConnection.new
    @trello = TrelloConnection.new
  end

  def run
    @github.unassigned_pull_requests.each do |issue|
      issue_id = issue[:number]
      issue_title = issue[:title]
      puts "*** Checking unassigned github pull request: #{issue_title}"
      card_id = issue_title.split(/[_ -#\.]/).last.to_i
      if card = @trello.find_card_by_id(card_id)
        puts "Found matching trello card: #{card.name}"
        reviewer = select_reviewer(issue, card)
        if reviewer
          @github.add_assignee(issue_id, reviewer['github_username'])
          @github.reviewer_comment(issue_id, reviewer['github_username'], card)
          comment = "@#{reviewer['trello_username']} will review https://github.com/#{@github.repo}/issues/#{issue_id}"
          @trello.comment_on_card(comment, card)
          @trello.move_card_to_list(card, 'In review')
        else
          puts "Could not find a reviewer for card: #{card.name}"
        end
      else
        puts "No matching card found (id #{card_id})"
      end
    end

  end

  def select_reviewer(issue, card)
    reviewers = MEMBERS_CONFIG['members']
    # remove people on vacation
    members_on_vacation = Vacations.members_on_vacation
    reviewers = reviewers.reject{|r| members_on_vacation.include? r['suse_username'] }
    # remove trello card owner
    reviewers = reviewers.reject{|r| card.members.map(&:username).include? r['trello_username'] }
    reviewer = reviewers.sample
    puts "Selected reviewer: #{reviewer['name']} from pool #{reviewers.map{|r| r['name']}}" if reviewer
    reviewer
  end

end
