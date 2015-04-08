require 'net/telnet'

class Vacations

  def self.find_vacations(username)
    vacations = []
    tn = Net::Telnet.new('Host' => 'present.suse.de', 'Port' => 9874, 'Binmode' => false)
    tn.cmd("#{username}").split("\n").each do |line|
      if line =~ /\S{3} #{Time.now.year}-\d\d-\d\d/
        dates = []
        line.split(" ").each do |date|
          dates.push(date) if date =~ /#{Time.now.year}-\d\d-\d\d/
        end
        dates[1] = dates[0] unless dates[1]
        vacations.push(Date.parse(dates[0])..Date.parse(dates[1]))
      end
    end
    tn.close
    vacations
  end

  def self.members_on_vacation
    members_on_vacation = MEMBERS_CONFIG['members'].collect do |member|
      username = member['suse_username']
      username if (username && Vacations.find_vacations(username).any? { |v| v === Date.today })
    end
    members_on_vacation.compact
  end

end
