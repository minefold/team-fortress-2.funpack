require 'spec_helper'
require 'steam_id'

describe SteamID do
  describe '#to_i' do
    it "converts from STEAM_X style" do
      SteamID.new("STEAM_0:1:5797670").to_i.
        should == 76561197971861069
    end
  end
end