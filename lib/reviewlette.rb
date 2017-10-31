require 'reviewlette/trello_board'

require 'reviewlette/github_repository'

require 'reviewlette/request'
require 'reviewlette/pull_request'

require 'yaml' # ??

class Reviewlette
  def initialize(repos:, members:, board_id:)
    @repos = repos
    @members = members
    @trello = TrelloBoard.new(board_id)
  end

  def run
    @repos.each do |repo|
      puts "\nChecking repository #{repo}..."
      check_repo(repo)
    end
  end

  private

  def check_repo(name)
    repo = GithubRepository.new(name)

    unless repo.exists?
      puts "... does not exist!"
      return
    end

    repo.pull_requests.each do |issue|
      puts "Pull request: #{issue.title}"
      unless issue.trello_card_id
        puts '... has no card id.'
        next
      end

      card = @trello.find_card_by_id(issue.trello_card_id)
      unless card
        puts "... has no matching card on the board."
        next
      end

      puts "Trello card: #{card.name}"

      already_assigned_members = @members.select { |member| issue.reviewers.include? member.github_handle }
      wanted_number = how_many_should_review(issue.labels)

      if issue.reviewers.size < wanted_number
        reviewers = select_reviewers(card, wanted_number, already_assigned_members)
        if reviewers.empty?
          puts "No reviewers available."
          next
        end

        reviewer_names = reviewers.map { |r| r.github_handle }
        puts "Requesting review from #{reviewer_names.join(' and ')}"

        begin
          issue.request_reviewers(reviewer_names) \
          and issue.comment_reviewers(reviewer_names, card) \
          and @trello.comment_reviewers(card, repo.name, issue.id, reviewers) \
          and @trello.move_card_to_list(card, 'In review')
        rescue Octokit::UnprocessableEntity
          puts "Failed to request review from #{reviewer_names.join(' and ')}. Check the collaborator settings of this repository!"
        end
      else
        puts "Nothing to do here."
      end
      puts ''
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
