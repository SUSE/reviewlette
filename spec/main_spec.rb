require 'spec_helper'
require 'trello'
require 'octokit'
require '/home/jschmid/reviewlette/main'

#
# describe Github do
#   let(:repo) { 'jschmid1/reviewlette' }
#   let(:number) { 5 }
#   it 'is merged' do
#     @github = Github.new
#     @github.
#   end
# end


describe "die" do
  it "dies" do
    die_pls.should == "die pls"
  end
end


describe Github do
  describe "init" do
    it "inits" do
      @gh = Github.new
      @gh.init.should be_true
    end
  end
  describe "assignee?" do
    it "assigns" do
      @gh.assignee?(@repo).should be_true
    end
  end
end
#
#       Failures:
#
#           1) Github assignee? assigns
#       Failure/Error: @gh.assignee?(@repo).should be_true
#       NoMethodError:
#           undefined method `assignee?' for nil:NilClass
#      # ./spec/main_spec.rb:34:in `block (3 levels) in <top (required)>'
#
# Finished in 1.66 seconds
# 3 examples, 1 failure
#
# Failed examples:
#
# rspec ./spec/main_spec.rb:33 # Github assignee? assigns
#
#     end
#   end
# end
