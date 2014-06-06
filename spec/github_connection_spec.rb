require 'spec_helper'


describe Reviewlette::GithubConnection do

  subject { Reviewlette::GithubConnection }

  describe '.new' do

    it 'populates @repo with repo string' do
      expect(subject.new.repo).to be_a_kind_of String
    end

    it 'sets up Github connection' do
      config = Reviewlette::GithubConnection::GITHUB_CONFIG
      expect(Octokit::Client).to receive(:access_token=).with(config['token']).and_call_original
      subject.new
    end

  end
  describe '#pull_merged?' do

    let( :connection ) { subject.new }

    it 'checks if the pull is merged' do
      stub_request(:get, "https://api.github.com/repos/aa/pulls/5/merge")
      expect(subject.new.client).to receive(:pull_merged?).and_return true
      connection.pull_merged?('aa', 5)
    end

  end


  describe '#add_assignee' do
    let( :connection ) { subject.new }


    it 'adds an assignee to the gh issue' do

    end
  end
end