require 'spec_helper'
require 'settings'

describe Settings do
  context '#erb' do
    it "erbs" do
      s = Settings.new("mp_maxrounds" => 5)
      result = s.erb('mp_maxrounds <%= mp_maxrounds %>')
      result.should == 'mp_maxrounds 5'
    end
  end
end