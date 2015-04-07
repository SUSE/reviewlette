require 'spec_helper'

describe Vacations do

  subject { Vacations }

  describe '.find_vacations' do

    it 'parses the vacations dates out of tel' do
      expect_any_instance_of(Net::Telnet).to receive(:cmd).with('testuser1').and_return "Absence    : Thu 2015-04-02 - Tue 2015-04-07"

      vacations = subject.find_vacations('testuser1')
      expect(vacations).to be_kind_of(Array)
      expect(vacations).to eq([Date.parse('2015-04-02')..Date.parse('2015-04-07')])
    end

  end


  describe '.members_on_vacation' do

    it 'finds members on vacation' do
      MEMBERS_CONFIG['members'] = [{'suse_username' => 'testuser1'}, {'suse_username' =>'testuser2'}, {'suse_username' =>'testuser3'}]
      allow(subject).to receive(:find_vacations).with('testuser1').and_return [(Date.today - 1)..(Date.today + 2)]
      allow(subject).to receive(:find_vacations).with('testuser2').and_return [(Date.today - 1)..(Date.today - 1)]
      allow(subject).to receive(:find_vacations).with('testuser3').and_return []

      expect(subject.members_on_vacation).to be_kind_of(Array)
      expect(subject.members_on_vacation).to eq(['testuser1'])
    end

  end

end
