require 'spec_helper'
require 'brock'
require 'settings'

describe Settings do
  let(:definitions) do
    [{
      "name" => "mp_maxrounds",
      "type" => "integer",
      "label" => "Max Rounds",
      "description" => "Maximum number of rounds to play before server changes maps.",
      "default" => 5
    }]
  end

  describe 'schema field method' do
    it "has value" do
      s = Settings.new(definitions, mp_maxrounds: 77)

      s.mp_maxrounds.should == 77
    end

    it "has default" do
      s = Settings.new(definitions)

      s.mp_maxrounds.should == 5
    end
  end

  describe 'values field method' do
    it 'has value' do
      s = Settings.new(definitions, server: '1234')
      s.server.should == '1234'
    end
  end

  describe '#erb' do
    it "erbs" do
      s = Settings.new(definitions)
      result = s.erb('mp_maxrounds <%= mp_maxrounds %>')
      result.should == 'mp_maxrounds 5'
    end
  end
end
