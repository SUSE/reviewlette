require 'json'
require 'net/http'
require 'net/https'
require 'net/smtp'


module Parse
  class Contributers
    def get_names
      repo = Octokit.repo 'SUSE/smt'
      #using smt because i cant access the private repo happy-customer yet
      @array =[]
      suse = repo.rels[:contributors].get.data
      suse.each do |a|
        name = a[:login]
        @array.push(name)
    end
    end
  end
end