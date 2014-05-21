require 'json'
require 'net/http'
require 'net/https'
require 'net/smtp'


module Parse
  class Contributers
    def get_names
      $name_list =[]
      repo = Octokit.repo 'SUSE/smt'
      #using smt because i cant access the private repo happy-customer yet
      suse = repo.rels[:contributors].get.data
      suse.each do |a|
        name = a[:login]
        $name_list.push(name)
    end
    end
  end
end