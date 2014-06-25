require 'spec_helper'

describe Reviewlette do

  subject { Reviewlette }

  describe '.spin!' do
    let ( :connection ) { subject.new }

    it 'spins it' do
      allow(subject).to receive(:spin!).with(no_args).and_return true
      expect(subject.spin!).to eq true
      #testing some air
    end
  end

  describe '.main' do
    it 'runs all the stuff' do
      allow(subject).to receive(:main).with(no_args).and_return true
      expect(subject.main).to eq true
      #testing some air again
    end
  end
end
