require 'spec_helper'

describe Reviewlette::Database do


  subject { Reviewlette::Database.new }

  describe '#count_up' do

    it 'increases the reviews-count by one for each pullrequest taken' do
      allow(subject).to receive(:count_up).and_return true
    end
  end
end