require 'spec_helper'

describe Vacations do
  subject { Vacations }

  let(:members_config) { { members: [member1, member2, member3] } }
  let(:member1) { { 'suse_username' => 'testuser1' } }
  let(:member2) { { 'suse_username' => 'testuser2' } }
  let(:member3) { { 'suse_username' => 'testuser3' } }
  let(:timestamp) { 'Absence    : Thu 2016-04-02 - Tue 2016-04-07' }

  describe '.find_vacations' do
    it 'parses the vacations dates out of tel' do
      stub_telnet = double
      expect(stub_telnet).to receive(:cmd).with('testuser1').and_return(timestamp)
      expect(stub_telnet).to receive(:close).and_return(true)

      expect(Net::Telnet).to receive(:new).and_return(stub_telnet)
      vacations = subject.find_vacations('testuser1')

      expect(vacations).to be_kind_of(Array)
      expect(vacations).to eq([Date.parse('2016-04-02')..Date.parse('2016-04-07')])
    end
  end

  describe '.members_on_vacation' do
    it 'finds members on vacation' do
      allow(subject).to receive(:find_vacations).with('testuser1').and_return [(Date.today - 1)..(Date.today + 2)]
      allow(subject).to receive(:find_vacations).with('testuser2').and_return [(Date.today - 1)..(Date.today - 1)]
      allow(subject).to receive(:find_vacations).with('testuser3').and_return []

      expect(subject.members_on_vacation(members_config[:members])).to be_kind_of(Array)
      expect(subject.members_on_vacation(members_config[:members])).to eq(['testuser1'])
    end
  end
end
