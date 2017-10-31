class Reviewlette
  class Request
    attr_reader :assignees
    attr_reader :author
    attr_reader :id
    attr_reader :labels
    attr_reader :repo
    attr_reader :reviewers
    attr_reader :title
    attr_reader :url

    def initialize(response:, repo:)
      @repo = repo
      set_instance_variables_from_api(response)
    end

    def trello_card_id
      title.match(/\d+?$/)[0] rescue nil
    end
  end
end
