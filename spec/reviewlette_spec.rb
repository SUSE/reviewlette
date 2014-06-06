require 'spec_helper'

describe Reviewlette do

  subject { Reviewlette }

  describe '.spin!' do
    it 'spins it' do
      expect(Reviewlette::TrelloConnection).to receive :new
      subject.spin!
    end
  end

end
