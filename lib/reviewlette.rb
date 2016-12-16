require 'reviewlette/trello_connection'
require 'reviewlette/github_connection'
require 'yaml'

class Reviewlette
  def initialize(members:, github_config: nil, trello_config: nil)
    @trello  = TrelloConnection.new(trello_config)
    @github  = github_config || YAML.load_file("#{File.dirname(__FILE__)}/../config/github.yml")
    @members = members
  end

  def run
    @github['repos'].each do |repo|
      puts "Checking repository #{repo}..."
      check_repo(repo, @github['token'])
    end
  end

  def check_repo(repo_name, token)
    repo = GithubConnection.new(repo_name, token)

    unless repo.repo_exists?
      puts "Repository #{repo_name} does not exist. Check your configuration"
      return
    end

    repo.pull_requests.each do |issue|
      issue_id = issue[:number]
      issue_title = issue[:title]
      issue_labels = repo.labels(issue_id)

      puts "*** Checking GitHub pull request: #{issue_title}"
      matched = issue_title.match(/\d+[_'"]?$/)

      unless matched
        puts 'Pull request not assigned to a trello card'
        next
      end

      card_id = matched[0].to_i
      card    = @trello.find_card_by_id(card_id)

      unless card
        puts "No matching card found (id #{card_id})"
        next
      end

      puts "Found matching trello card: #{card.name}"

      assignees = issue[:assignees].map(&:login)
      already_assigned_members = @members.select { |m| assignees.include? m.github_handle }
      wanted_number = how_many_should_review(issue_labels)

      if assignees.size < wanted_number
        reviewers = select_reviewers(card, wanted_number, already_assigned_members)
        if reviewers.empty?
          puts "Could not find a reviewer for card: #{card.name}"
          next
        end
        repo.add_assignees(issue_id, reviewers.map { |r| r.github_handle } )
        repo.comment_reviewers(issue_id, reviewers, card)
        @trello.comment_reviewers(card, repo_name, issue_id, reviewers)
        @trello.move_card_to_list(card, 'In review')
        already_assigned_members
      end


    end
  end

  def select_reviewers(card, number = 1, already_assigned = [])
    reviewers = @members
    reviewers.reject! { |r| card.members.map(&:username).include? r.trello_handle }
    reviewers -= already_assigned

    reviewers.sample(number - already_assigned.size) + already_assigned
  end

  def how_many_should_review(labels)
    return 2 if labels.include? '2 reviewers'
    1
  end
end
