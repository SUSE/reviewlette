require 'spec_helper'


describe Reviewlette::GithubConnection do

  subject { Reviewlette::GithubConnection }

  describe '.new' do

    it 'sets up the authorization to the github api and sets the static repo' do
      expect(subject.new.client).to be_a_kind_of Github::Authentication
    end
  end
end