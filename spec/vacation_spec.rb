require 'spec_helper'

describe Reviewlette::Vacations do


  describe '.find_vacation' do

    it 'parses the vacations dates out of tel' do
      expect(Reviewlette::Vacations.find_vacations('jschmid')).to be_a_kind_of Array
    end
  end
end