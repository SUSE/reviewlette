class Reviewlette
  class PullRequest < Request
    def set_instance_variables_from_api(response)
      @id = response.number
      @title = response.title
      @author = response.user.login
      @reviewers = response.requested_reviewers
      @url = response.html_url
      @labels = [] # TODO: !?!
    end

    def request_reviewers(reviewer_names)
      Octokit.request_pull_request_review(@repo, @id, reviewer_names)
    end

    def comment_reviewers(reviewers, trello_card)
      reviewers = reviewers.map { |r| "@#{r}" }.join(' and ')

      comment = <<-eos
  #{reviewers} will review your pull request :dancers: check #{trello_card.url}
  #{reviewers}: Please review this pull request using our guidelines:
  * test for acceptance criteria / functionality
  * check if the new code is covered with tests
  * check for unintended consequences
  * encourage usage of the boyscout rule
  * make sure the code is architected in the best way
  * check that no unnecessary technical debt got introduced
  * make sure that no unnecessary FIXMEs or TODOs got added
      eos

      Octokit.add_comment(@repo, @id, comment)
    end
  end
end
