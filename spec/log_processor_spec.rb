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
        events = [
          %Q(hostname: minefold.com TF2 Server),
          %Q(players : 0 (24 max)),
          %Q(# userid name                uniqueid            connected ping loss state  adr)
        ].map do |line|
          subject.process_line(line)
        end

        events.last[0].should match_event('players_list',
          auth: 'steam',
          uids: []
        )
      end
    end

    it 'returns connected players' do
      events = [
        %Q(hostname: minefold.com TF2 Server),
        %Q(version : 1.2.5.0/23 5191 secure),
        %Q(players : 2 (24 max)),
        %Q(# userid name                uniqueid            connected ping loss state  adr),
        %Q(#      2 "whatupdave"        STEAM_0:1:12345678  00:47      132   75 spawning 10.10.10.1:27005),
        %Q(#      3 "chrsllyd"          STEAM_0:1:23456789  00:47      132   75 spawning 10.10.10.1:27005),
      ].map do |line|
        subject.process_line(line)
      end

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
      events = [
        %Q(hostname: minefold.com TF2 Server),
        %Q(players : 2 (24 max)),
        %Q(# userid name                uniqueid            connected ping loss state  adr),
        %Q(#      2 "whatupdave"        STEAM_0:1:12345678  00:47      132   75 spawning 10.10.10.1:27005),
        %Q(#      3 "chrsllyd"          STEAM_0:1:23456789  00:47      132   75 spawning 10.10.10.1:27005),
        %Q(hostname: minefold.com TF2 Server),
        %Q(players : 0 (24 max)),
        %Q(# userid name                uniqueid            connected ping loss state  adr),
      ].map do |line|
        subject.process_line(line)
      end

      events[7][0].should match_event('player_disconnected', auth: 'steam', uid: '76561197984957085', nick: 'whatupdave')
      events[7][1].should match_event('player_disconnected', auth: 'steam', uid: '76561198007179307', nick: 'chrsllyd')
      events[7][2].should match_event('players_list',
        auth: 'steam',
        uids: []
      )
    end
  end
end
