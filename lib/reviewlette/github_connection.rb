module Reviewlette
  class GithubConnection
    TRELLO_CONFIG = ::YAML.load_file('.trello.yml')
  end
end
