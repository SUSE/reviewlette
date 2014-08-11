require 'net/telnet'
module Reviewlette

  class Vacations

    def self.find_vacations(username)
      vacations = []
      tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => false)
      collect = false
      tn.cmd(username) do |data|
        data.split("\n").each do |l|
          collect = true if l =~ /^Absence/
          next unless collect
          if l[0,1] == "-"
            collect = false
            next
          end
          dates = []
          l.split(" ").each do |date|
            unless date =~ /#{Time.now.year}/
              next
            end
            dates.push(date)
          end
          case dates.size
            when 1
              vacations.push("#{dates[0]}")
            when 2
              vacations.push("#{dates[0]} - #{dates[1]}")
            else
          end
        end
      end
      tn.close
      vacations
    end
  end
end