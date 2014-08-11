require 'spec_helper'

describe Reviewlette::Database do


  subject { Reviewlette::Database.new }

  describe '#count_reviews' do

    it 'counts the reviews done by a single user' do
      to_be_counted = [1,2,3,4]
      expect(subject.instance_variable_get(:@reviews)).to receive(:where).and_return to_be_counted
      expect(to_be_counted).to receive(:count).and_return to_be_counted.count
      subject.count_reviews(subject.reviewer.first.values[1])
    end
  end

  describe '#get_users_gh_entries' do
    it 'gets all github usernames in #Array' do
      expect(subject.reviewer).to receive(:map).and_return [['jschmid']]
      subject.get_users_gh_entries
    end
  end

  describe '#add_pr_to_db' do

    it 'writes the name of the pr to db' do

      expect(subject.reviews).to receive(:insert)
      expect(subject).to receive(:count_up).with(subject.reviewer.first.values[1])
      subject.add_pr_to_db('review_123', subject.reviewer.first.values[1])
    end
  end

end