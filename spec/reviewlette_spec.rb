require 'spec_helper'

describe Reviewlette do

  # set instance variable from local variable
  def instance_variable!(variable_name)
    Reviewlette.instance_variable_set("@#{variable_name}", send(variable_name.to_sym))
  end

  let(:number) { 23 }
  let(:title) { 'title' }
  let(:body) { 'body' }
  let(:githubname) { 'gitty' }
  let(:trelloname) { 'jschmid' }
  let(:github_stub) { github_stub }
  let(:board) { stub_boards_call }
  let(:repo) { 'repo/repo' }
  let(:id) { 23 }
  let(:card) { stub_card_call }
  let(:logger) { double 'logger' }
  let(:repos) { %w[repo/repo, repos/repos] }
  let(:trello_connection) { double 'trello_connection' }
  let(:reviewer) {double 'reviewer'}
  let(:db) {Reviewlette::Database.new}
  let(:github_connection) { double 'github_connection' }
  let(:full_comment) { @full_comment = "@#{trelloname} will review https://github.com/#{repo}/issues/#{number.to_s}" }
  let(:exp) { AlreadyAssignedException }

  describe '.spin' do
    before do
      instance_variable! :github_connection
      instance_variable! :repo
      instance_variable! :trello_connection
      instance_variable! :id
      instance_variable! :repos
      instance_variable! :title
      instance_variable! :body
      instance_variable! :number
      instance_variable! :logger
      instance_variable! :repos
      issue = { number: 1, title: 'Title', body: 'Body' }
      expect(Reviewlette).to receive(:setup)
      expect(Reviewlette).to receive(:get_available_repos).and_return [repo]
      expect(Reviewlette).to receive(:get_unassigned_github_issues).and_return [issue]
      expect(Reviewlette).to receive(:find_card)
      expect(Reviewlette).to receive(:update_vacations)
    end

    it 'spins until find_id' do
      expect(Reviewlette).to receive(:find_id).and_return false
      expect(Reviewlette).to_not receive(:set_reviewer)
      expect(Reviewlette).to_not receive(:transform_name)
      expect(Reviewlette).to_not receive(:add_reviewer_on_github)
      expect(Reviewlette).to_not receive(:comment_on_github)
      expect(Reviewlette).to_not receive(:add_to_trello_card)
      expect(Reviewlette).to_not receive(:comment_on_trello)
      expect(Reviewlette).to_not receive(:move_to_list)
      expect(Reviewlette).to_not receive(:comment_on_error)
      Reviewlette.spin
    end

    it 'spins until set_reviewer' do
      expect(Reviewlette).to receive(:find_id).and_return true
      expect(Reviewlette).to receive(:set_reviewer)
      expect(Reviewlette).to_not receive(:transform_name)
      expect(Reviewlette).to_not receive(:add_reviewer_on_github)
      expect(Reviewlette).to_not receive(:comment_on_github)
      expect(Reviewlette).to_not receive(:add_to_trello_card)
      expect(Reviewlette).to_not receive(:comment_on_trello)
      expect(Reviewlette).to_not receive(:move_to_list)
      expect(Reviewlette).to receive(:comment_on_error)
      Reviewlette.spin
    end

    it 'spins until set_reviewer' do
      expect(Reviewlette).to receive(:find_id).and_return true
      expect(Reviewlette).to receive(:set_reviewer).and_return true
      expect(Reviewlette).to receive(:transform_name)
      expect(Reviewlette).to receive(:add_reviewer_on_github)
      expect(Reviewlette).to receive(:comment_on_github)
      # expect(Reviewlette).to receive(:add_to_trello_card)
      expect(Reviewlette).to receive(:comment_on_trello)
      expect(Reviewlette).to receive(:move_to_list)
      Reviewlette.instance_variable_set(:@reviewer, 'hi')
      Reviewlette.instance_variable_set(:@db, db)
      allow(@reviewer).to receive(:username)
      expect(db).to receive(:add_pr_to_db).with('Title', @reviewer.username)
      expect(Reviewlette.instance_variable_set(:@reviewer, nil))
      expect(Reviewlette).to_not receive(:comment_on_error)
      Reviewlette.spin
    end
  end

  describe '.get_available_repos' do

    it 'pulls in an array on avaialble repos' do

      instance_variable! :repos
      expect(Reviewlette.instance_variable_get(:@repos)).to be_kind_of Array #ok
      Reviewlette.get_available_repos
    end
  end

  describe '#find_card' do

    it 'finds the card by Github title' do
      line = 'Review_1337_name_of_pr_trello_shortid_454'
      pulls = { number: 1 }
      expect(Reviewlette).to receive(:match_pr_id_with_issue_id).and_return [pulls]
      allow(Reviewlette.find_card(line)).to receive(:match_pr_id_with_issue_id).and_return Array
    end

  end

  describe '.fetch_branch' do

    it 'gets the branch_name from github' do
      branch_name = 'review_github_branch_name_trello_23'
      subject.instance_variable_set(:@pullreq_ids, {number: 1})
      split_branch_name = branch_name.split('_')
      instance_variable! :github_connection
      expect(Reviewlette.instance_variable_get(:@pullreq_ids)).to receive_message_chain(:values, :index => 0).and_return number
      expect(github_connection).to receive(:get_branch_name).and_return branch_name
      expect(branch_name).to receive(:split).with('_').and_return split_branch_name
      expect(split_branch_name).to receive_message_chain(:last, :to_i)
      Reviewlette.fetch_branch
    end
  end

  describe '.comment_on_error' do
    it 'posts a comment with the arror message on trello' do
      instance_variable! :trello_connection
      expect(trello_connection).to receive(:comment_on_card).with("Skipped Issue 1 because everyone on the team is assigned to the card", nil)
      Reviewlette.comment_on_error
    end
  end

  describe '.get_unassigned_github_issues' do
    it 'returns all unassigned issues' do
      instance_variable! :github_connection
      expect(github_connection).to receive_message_chain(:list_issues, :select)
      Reviewlette.get_unassigned_github_issues
    end
  end

  describe '.match_pr_id_with_issue_id' do

    it 'matches issue id with pr id' do
      instance_variable! :github_connection
      instance_variable! :repo
      pulls  = {number: 1}
      allow(github_connection).to receive(:list_pulls).and_return [pulls]
      allow(pulls).to receive(:number).and_return [1]
      Reviewlette.match_pr_id_with_issue_id
    end
  end


  describe '.transform_name' do
    it 'transforms trelloname to github name' do
      instance_variable! :trelloname
      Reviewlette.transform_name
      expect(Reviewlette.instance_variable_get("@githubname")).to be_a_kind_of String
    end
  end

  describe '.find_id' do
    before do
      instance_variable! :id
      instance_variable! :trello_connection
    end

    it 'finds the id' do
      expect(trello_connection).to receive(:find_card_by_id).with(id).and_return card
      Reviewlette.find_id
    end

    it 'does not find the id' do
      Reviewlette.instance_variable_set("@id", 0)
      Reviewlette.instance_variable_set("@logger", logger)
      expect(logger).to receive(:warn)
      expect(Reviewlette.find_id).to be false
    end
  end

  describe '.set_reviewer' do

    before do
      Reviewlette.instance_variable_set("@reviewer", nil)
    end

    it 'sets the reviewer' do
      reviewer = double('reviewer')
      instance_variable! :trello_connection
      instance_variable! :card
      expect(trello_connection).to receive(:determine_reviewer).with(card).and_return reviewer
      expect(reviewer).to receive(:username).and_return String
      expect(reviewer).to receive(:username).and_return String
      Reviewlette.set_reviewer
    end

    it 'fails to set the reviewer because everyone on the team is assigned to the card' do
      reviewer = double('reviewer')
      instance_variable! :trello_connection
      instance_variable! :card
      Reviewlette.instance_variable_set("@logger", logger)
      expect(trello_connection).to receive(:determine_reviewer).with(card).and_raise(Reviewlette::AlreadyAssignedException)
      allow(card).to receive(:short_id).and_return 3
      expect($stdout).to receive(:puts)
      expect(logger).to receive(:warn)
      expect(Reviewlette.set_reviewer).to eq false
    end
  end

  describe '.add_reviewer_on_github' do
    it 'adds the reviewer on github as assignee' do
      instance_variable! :github_connection
      instance_variable! :title
      instance_variable! :body
      instance_variable! :number
      instance_variable! :githubname
      expect(github_connection).to receive(:add_assignee).with('repo/repo', 23, 'title', 'body', 'gitty').and_return true
      Reviewlette.add_reviewer_on_github
    end
  end

  describe '.comment_on_github' do
    it 'comments on the issue' do
      instance_variable! :card
      instance_variable! :number
      instance_variable! :githubname
      instance_variable! :github_connection
      expect(card).to receive(:url).and_return 'www.example.url'
      expect(github_connection).to receive(:comment_on_issue).with('repo/repo', 23, 'gitty', 'www.example.url').and_return true
      Reviewlette.comment_on_github
    end
  end

  describe '.add_to_trello_card' do
    it 'adds a reviewer to the right trello card' do
      instance_variable! :trello_connection
      instance_variable! :reviewer
      instance_variable! :card
      expect(trello_connection).to receive(:add_reviewer_to_card).with(reviewer, card).and_return true
      Reviewlette.add_to_trello_card
    end

    it 'rescues with: already assigned' do
      instance_variable! :trello_connection
      expect{Reviewlette.add_to_trello_card}.to raise_exception
      # Reviewlette.add_to_trello_card
    end
  end

  describe '.comment_on_trello' do
    before do
      instance_variable! :repo
      instance_variable! :trelloname
      instance_variable! :number
      instance_variable! :trello_connection
      instance_variable! :full_comment
      instance_variable! :card
    end

    it 'puts a comment on the trello card ' do
      expect(full_comment).to eq '@jschmid will review https://github.com/repo/repo/issues/23'
    end

    it 'actually posts' do
      expect(trello_connection).to receive(:comment_on_card).with(full_comment, card).and_return true
      Reviewlette.comment_on_trello
    end
  end

  describe '.move_to_list' do
    before do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :card
      instance_variable! :repo
      instance_variable! :id
    end

    it 'moves the card to #Done list if the pull is merged' do
      expect(trello_connection).to receive(:find_column).with('Done').and_return 'Done'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'Done').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return true
      Reviewlette.move_to_list
    end

    it 'moves the card to #in-Review list if the pull is not merged' do
      expect(trello_connection).to receive(:find_column).with('In review').and_return 'In review'
      expect(trello_connection).to receive(:move_card_to_list).with(card,'In review').and_return Object
      expect(github_connection).to receive(:pull_merged?).with(repo, id).and_return false
      Reviewlette.move_to_list
    end
  end

  describe '.setup' do
    before do
      instance_variable! :github_connection
      instance_variable! :trello_connection
      instance_variable! :board
      instance_variable! :repo
    end

    it 'sets up repo variable' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@repo')).to be_kind_of String #ok
    end
    it 'sets up the github_connection' do
      Reviewlette.setup
      expect(github_connection).to be_kind_of Object #how to call this kind of structure
    end

    it 'sets up the trello_connection' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@trello_connection')).to be_kind_of Object #same
    end

    it 'sets up the board' do
      Reviewlette.setup
      expect(Reviewlette.instance_variable_get('@board')).to be_kind_of Object #same
    end
  end

  describe '.update_vacations' do

    it 'updates vacationsstatus based on tel vacation output' do
      vacations = ['2015-01-07', '2015-01-25']
      instance_variable_set(:@vacations, vacations)
      instance_variable_set(:@db, db)
      expect(Reviewlette::Vacations).to receive(:find_vacations).at_least(:once)
      expect(Reviewlette).to receive(:evaluate_vacations).at_least(:once)
      Reviewlette.update_vacations
    end
  end

  describe '.evaluate_vacations' do

    it 'checks if vacation state is true' do
      today = Date.today
      allow(subject).to receive(:parse_vacations).and_return [[today]]
      subject.evaluate_vacations('jschmid')
    end

    it 'checks if vacation state is false' do
      allow(subject).to receive(:parse_vacations).and_return [1,2]
      subject.evaluate_vacations('jschmid')
    end
  end


  describe '.parse_vacations' do

    it 'parses Date in proper format' do
      # vacations = ["2014-08-23 - 2014-09-14", "2014-10-03 - 2014-10-05", "2014-12-24 - 2014-12-28"]
      # split = [["2014-08-23", "2014-09-14"], ["2014-10-03", "2014-10-05"], ["2014-12-24", "2014-12-28"]]
      # ret = [['Sat, 23 Aug 2014', 'Sun, 14 Sep 2014'], ['Fri, 03 Oct 2014', 'Sun, 05 Oct 2014'], ['Wed, 24 Dec 2014', 'Sun, 28 Dec 2014']]
      # instance_variable_set(:@vacations, vacations)
      # instance_variable_set(:@split, split)
      # expect(instance_variable_get(:@vacations)).to receive(:map).and_return split
      # expect(instance_variable_get(:@split)).to receive(:map).and_return ret
      # subject.parse_vacations
    end
  end
end
