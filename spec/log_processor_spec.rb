require 'spec_helper'
require 'log_processor'

RSpec::Matchers.define :match_event do |type, opts|
  match do |a|
    a.delete(:ts)
    a == { event: type }.merge(opts || {})
  end
end

describe LogProcessor do
  subject { LogProcessor.new }

  it "detects started" do
    subject.process_line(
      "Sending CMsgGameServerMatchmakingStatus ..."
    ).should match_event('started', msg: "Sending CMsgGameServerMatchmakingStatus ...")
  end

  context 'with steam accounts' do
    it "detects player_connected" do
      subject.process_line(
        %Q{"whatupdave<2><STEAM_0:1:123456><>" entered the game}
      ).should match_event('player_connected',
        account: 'STEAM_0:1:123456',
        account_type: 'steam',
        username: 'whatupdave')
    end

    it "detects player_disconnected" do
      subject.process_line(
        %Q{"whatupdave<2><STEAM_0:1:123456><>" disconnected (reason "gave up")}
      ).should match_event('player_disconnected',
        account: 'STEAM_0:1:123456',
        account_type: 'steam',
        username: 'whatupdave',
        reason: 'gave up'
      )
    end
  end

  context 'without steam accounts' do
    it 'detects player_connected' do
      subject.process_line(
        %Q{Client "whatupdave" connected (10.10.10.1:27005).}
      ).should match_event('player_connected',
        username: 'whatupdave',
        address: '10.10.10.1:27005'
      )
    end

    it 'detects player_disconnected' do
      subject.process_line(
        %Q{Dropped whatupdave from server (Disconnect by user.)}
      ).should match_event('player_disconnected',
        username: 'whatupdave',
        reason: 'Disconnect by user.'
      )
    end
  end

  context 'list' do
    context 'without steam accounts' do
      it 'returns connected players' do
        events = [
          %Q(<slot:userid:"name">),
          %Q(0:2:"whatupdave"),
          %Q(1:3:"chrisllyd"),
          %Q(2 users),
        ].map do |line|
          subject.process_line(line)
        end

        events.last.should match_event('players_list',
          usernames: %w(whatupdave chrisllyd)
        )
      end
    end
  end
end
