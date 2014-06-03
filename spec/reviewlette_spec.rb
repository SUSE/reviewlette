require 'spec_helper'

describe Reviewlette do

  subject { Reviewlette }

  describe '.spin!' do
    it 'finds a card' do
      expect(Reviewlette::TrelloConnection).to receive :new
      subject.spin!
    end
  end

end
