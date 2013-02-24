# encoding: UTF-8

require 'json'
require 'time'
require 'set'
require 'steam_id'

class LogProcessor
  def initialize
    @mode = :normal
    @current_players = {}
    @prev_players = {}
  end

  def process_line(line)
    line = line.force_encoding('UTF-8')
    line = line.gsub(/L [\d\/]+ - [\d:]+ /, '').strip

    case @mode
    when :normal
      process_normal_line(line)
    when :listing
      process_listing_line(line)
    when :stats
      process_stats_line(line)
    end
  end

  def process_normal_line(line)
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
      @mode = :listing
      @user_count = nil
      @current_players = {}
      nil

    when /^CPU/
      @mode = :stats
      nil

    else
      event 'info', msg: line.strip
    end
  end

  def emit_players_list
    if @user_count == @current_players.size
      @mode = :normal

      events = []
      (@current_players.keys - @prev_players.keys).each do |new_player|
        if new_player.valid?
          events << event('player_connected', auth: 'steam', uid: new_player.to_i.to_s, nick: @current_players[new_player])
        end
      end
      (@prev_players.keys - @current_players.keys).each do |old_player|
        if old_player.valid?
          events << event('player_disconnected', auth: 'steam', uid: old_player.to_i.to_s, nick: @prev_players[old_player])
        end
      end
      @prev_players = @current_players

      uids = @current_players.keys.select{|steam_id| steam_id.valid? }.map(&:to_i).map(&:to_s)
      events << event('players_list', auth: 'steam', uids: uids)
    end
  end

  def process_listing_line(line)
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

  def process_stats_line(line)
    @mode = :normal
    
    parts = line.split
    event 'stats',
      cpu: parts[0].to_f,
      bytes_in: parts[1].to_f,
      bytes_out: parts[2].to_f,
      uptime_mins: parts[3].to_i,
      map_changes: parts[4].to_i,
      fps: parts[5].to_f,
      players: parts[6].to_i,
      connects: parts[7].to_i
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
