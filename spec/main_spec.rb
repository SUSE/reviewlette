require 'spec_helper'
require 'home/jschmid/reviewlette/main.rb'



describe Github do
  subject { Github.new() }
  describe "#init" do
    it "creates a new Github init object" do
      subject.should be_an_instance_of Github
    end
  end


  describe "#assignee?" do
    it "checks for an unassigend Issue" do
      subject.should be_an_instance_of Github
    end
  end

  describe "#pull_merged?" do
    it "checks if pull is merged" do
      subject.pull_merged?(repo, number).should eql (false||true)
    end
  end
end