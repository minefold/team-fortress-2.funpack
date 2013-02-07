require 'spec_helper'
require 'log_processor'

RSpec::Matchers.define :match_event do |type, opts|
  match do |a|
    a.delete(:ts)
    { event: type }.merge(opts || {}) == a
  end
end

describe LogProcessor do
  subject { LogProcessor.new }

  def process(input)
    events = input.strip.split("\n").map do |line|
      subject.process_line(line.strip)
    end
  end

  it "detects started" do
    subject.process_line(
      "Sending CMsgGameServerMatchmakingStatus ..."
    ).should match_event('started', msg: "Sending CMsgGameServerMatchmakingStatus ...")
  end

  describe 'player_connected' do
    it 'returns player with nick' do
      subject.process_line(
        'Client "whatupdave" connected (10.10.10.1:27005).'
      ).should match_event(
        'player_connected',
        nick: 'whatupdave', address: '10.10.10.1:27005')
    end
  end

  describe 'list' do
    context 'when empty' do
      it 'returns empty list' do
        events = process <<-EOS
          hostname: minefold.com TF2 Server
          players : 0 (24 max)
          # userid name                uniqueid            connected ping loss state  adr
        EOS

        events.last[0].should match_event('players_list',
          auth: 'steam',
          uids: []
        )
      end
    end

    it 'returns connected players' do
      events = process <<-EOS
        hostname: minefold.com TF2 Server
        version : 1.2.5.0/23 5191 secure
        players : 2 (24 max)
        # userid name                uniqueid            connected ping loss state  adr
        #      2 "whatupdave"        STEAM_0:1:12345678  00:47      132   75 spawning 10.10.10.1:27005
        #      3 "chrsllyd"          STEAM_0:1:23456789  00:47      132   75 spawning 10.10.10.1:27005
      EOS

      events[5][0].should match_event('player_connected', auth: 'steam', uid: '76561197984957085', nick: 'whatupdave')
      events[5][1].should match_event('player_connected', auth: 'steam', uid: '76561198007179307', nick: 'chrsllyd')
      events[5][2].should match_event('players_list',
        auth: 'steam',
        uids: [
          SteamID.new('STEAM_0:1:12345678').to_i.to_s,
          SteamID.new('STEAM_0:1:23456789').to_i.to_s
        ]
      )
    end

    it 'returns disconnected players' do
      events = process <<-EOS
        hostname: minefold.com TF2 Server
        players : 2 (24 max)
        # userid name                uniqueid            connected ping loss state  adr
        #      2 "whatupdave"        STEAM_0:1:12345678  00:47      132   75 spawning 10.10.10.1:27005
        #      3 "chrsllyd"          STEAM_0:1:23456789  00:47      132   75 spawning 10.10.10.1:27005
        hostname: minefold.com TF2 Server
        players : 0 (24 max)
        # userid name                uniqueid            connected ping loss state  adr
      EOS

      events[7][0].should match_event('player_disconnected', auth: 'steam', uid: '76561197984957085', nick: 'whatupdave')
      events[7][1].should match_event('player_disconnected', auth: 'steam', uid: '76561198007179307', nick: 'chrsllyd')
      events[7][2].should match_event('players_list',
        auth: 'steam',
        uids: []
      )
    end

    it 'understands bots' do
      events = process <<-EOS
        hostname: minefold.com
        players : 2 (32 max)
        # userid name                uniqueid            connected ping loss state  adr
        #      4 "whatupdave"        STEAM_0:1:12345678  42:34      135    0 active 50.136.136.83:44207
        #     25 "Target Practice"   BOT                                     active
      EOS
      events[4][0].should match_event('player_connected', auth: 'steam', uid: SteamID.new('STEAM_0:1:12345678').to_i.to_s, nick: 'whatupdave')
      events[4][1].should match_event(
        'players_list',
        auth: 'steam',
        uids: [SteamID.new('STEAM_0:1:12345678').to_i.to_s])
    end
  end
end
