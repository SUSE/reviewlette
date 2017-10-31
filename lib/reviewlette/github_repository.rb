require 'octokit'

class Reviewlette
  class GithubRepository
    attr_accessor:name

    def initialize(name)
      @name = name
    end

    def pull_requests # memoize?
      Octokit.pull_requests(@name, state: :open).map do |api_response|
        PullRequest.new(response: api_response, repo: @name)
      end
    end

    def exists?
      Octokit.repository?(@name)
    end
  end
end
