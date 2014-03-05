require_relative 'spec_helper'
require_relative '/home/jschmid/reviewlette/test.rb'

describe 'reviewlette' do

  subject { Reviewlette.new }

  it 'return jschmid' do 
    expect(subject.namereturn).to eq( 'jschmid' )
    end 
  it 'exp calc' do
    expect(subject.exp(3)).to eq ( 9 )
  end 
  it 'random name return' do 
    expect(subject.randomname).to be_instance_of(String) 
    end
  it 'i picked this random name for you' do
    expect(subject.namecall).to be_instance_of(String)
  end

  it 'ensures that there is always a name to output' do
    subject.namecall
    expect(subject.name).not_to be_nil

  end
end
