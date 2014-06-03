require 'spec_helper'

describe Reviewlette do

  subject { Reviewlette }

  describe '.spin!' do
    it 'finds a card' do
      expect_any_instance_of(Reviewlette::TrelloConnection).to receive_message_chain(:board, :cards, :find).and_call_original
      subject.spin!
    end
  end

end
