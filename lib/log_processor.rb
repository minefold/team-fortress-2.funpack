# encoding: UTF-8

require 'json'
require 'time'
require 'set'
require 'steam_id'

class LogProcessor
  def initialize
    @listing = false
    @current_players = {}
    @prev_players = {}
  end

  def process_line(line)
    line = line.force_encoding('UTF-8')
    line = line.gsub(/L [\d\/]+ - [\d:]+ /, '').strip

    if @listing
      process_list_line(line)
    else
      process_regular_line(line)
    end
  end

  def process_regular_line(line)
    case line
    # no STEAM_ID
    when /^Client "(\w+)" connected \(([\d\.:]+)\).$/
      event 'player_connected', nick: $1, address: $2

    # no STEAM_ID
    when /^Dropped (\w+) from server \(([^\)]+)\)$/
      event 'player_disconnected', nick: $1, reason: $2

    when /\"([^\<]+).* say (.+)/
      event 'chat', username: $1, msg: $2.gsub(/^"|"?$/, '')

    when /^Sending CMsgGameServerMatchmakingStatus/
      event 'started', msg: line

    when /^hostname: /
      @listing = true
      @user_count = nil
      @current_players = {}
      nil

    else
      event 'info', msg: line.strip
    end
  end

  def emit_players_list
    if @user_count == @current_players.size
      @listing = false

      events = []
      (@current_players.keys - @prev_players.keys).each do |new_player|
        events << event('player_connected', auth: 'steam', uid: new_player.to_i.to_s, nick: @current_players[new_player])
      end
      (@prev_players.keys - @current_players.keys).each do |old_player|
        events << event('player_disconnected', auth: 'steam', uid: old_player.to_i.to_s, nick: @prev_players[old_player])
      end
      @prev_players = @current_players

      uids = @current_players.keys.select{|steam_id| !steam_id.bot? }.map(&:to_i).map(&:to_s)
      events << event('players_list', auth: 'steam', uids: uids)
    end
  end

  def process_list_line(line)
    case line
    when /^players\s+:\s+(\d+)\s+\(\d+ max\)$/
      @user_count = $1.to_i
      nil

    when /#\s+\d+\s+"([^"]+)"\s+([^ ]+)/
      @current_players[SteamID.new($2)] = $1
      emit_players_list
    else

      emit_players_list
    end
  end

  # chrsllyd<2><STEAM_0:1:123456><>
  def parse_connected_user(user)
    user =~ /([^<]+)<(\d+)><([^>]+)>/
    [$1, $2, SteamID.new($3)]
  end


  def event(event, options = {})
    {
      ts: Time.now.utc.iso8601,
      event: event,
    }.merge(options)
  end
end
