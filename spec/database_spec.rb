require 'spec_helper'

describe Reviewlette::Database do


  subject { Reviewlette::Database.new }


  describe '#count_up' do

    it 'increases the reviews-count by one for each pullrequest taken' do
      # instance_variable_set(:@reviewer, double('reviewer'))
      # expect(subject.reviewer).to receive_message_chain(:where, :update, :select, :first, :values, :first).and_return 3
      # subject.count_up('jschmid')
    end
  end

  describe '#add_pr_to_db' do

    it 'adds the name of the pullrequest to the database' do
      # instance_variable_set(:@reviewer, double('reviewer'))
      # expect(subject.reviewer).to receive(:insert).with(any_args)
      # expect(subject.add_pr_to_db('asd_23_23asd_123', 'jschmid')).to receive(:count_up)
      # subject.add_pr_to_db('asd_23_23asd_123', 'jschmid')
    end
  end
end