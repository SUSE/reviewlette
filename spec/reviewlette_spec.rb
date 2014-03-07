require_relative 'spec_helper'
require_relative '/home/jschmid/reviewlette/test.rb'

describe 'reviewlette' do

  subject { Reviewlette.new }

  it 'return jschmid' do 
    expect(subject.namereturn).to eq( 'jschmid' )
  end 
  it 'read from file and sample' do 
    expect(subject.readfromfile).not_to be_nil
    expect(subject.readfromfile).to be_instance_of(String) 
  end
  it 'i picked this random name for you' do
    expect(subject.namecall).to be_instance_of(String)
  end

  it 'ensures that there is always a name to output' do
    subject.namecall
    expect(subject.name).not_t be_nil
  end
end
