require 'spec_helper'
require 'steam_id'

describe SteamID do
  describe '#to_i' do
    it "converts to 64 bit style" do
      SteamID.new('STEAM_0:1:24804711').to_i.
        should == 76561198009875151
    end
  end

  describe '#to_s' do
    it "converts to STEAM_X style" do
      SteamID.new(76561198009875151).to_s.
        should == 'STEAM_0:1:24804711'
    end
  end
end