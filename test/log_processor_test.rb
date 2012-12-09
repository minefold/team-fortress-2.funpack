require 'turn/autorun'
require 'log_processor'

class JsonEvents < Array
  def puts(json)
    self << json
  end

  def pop
    JSON.load(self.shift)
  end
end

module MiniTest::Assertions
  def assert_contains(h1, h2)
    h2.each do |k, v|
      assert h1[k] == v, "Expected #{h1.inspect} to contain #{h2.inspect}. #{k} does not match"
    end
  end
end

Hash.infect_an_assertion :assert_contains, :must_contain, :do_not_flip

describe LogProcessor do
  let(:events) { JsonEvents.new }
  let(:processor) { LogProcessor.new(1234, events) }

  it "lists players with steamid" do
    processor.process_line(
      %Q{"chrsllyd<2><STEAM_0:1:1234560><>" entered the game})

    events.pop.must_contain(
      'event' => 'player_connected',
      'username' => 'STEAM_0:1:1234560')

    processor.players_list

    events.pop.must_contain(
      'event' => 'players_list',
      'usernames' => ['STEAM_0:1:1234560'],
    )

  end
end