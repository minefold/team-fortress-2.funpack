require 'json'
require 'time'
require 'set'
require 'steam_id'

class LogProcessor
  def initialize
    @listing = false
  end

  def process_line(line)
    line = line.gsub(/L [\d\/]+ - [\d:]+ /, '').strip

    if @listing
      process_list_line(line)
    else
      process_regular_line(line)
    end
  end

  def process_regular_line(line)
    case line
    # with STEAM_ID (these aren't occuring at the moment)
    when /^\"([^\<]+.*)\" entered the game$/
      username, slot, account = parse_connected_user($1)
      event 'player_connected',
        account: account.to_i, account_type: 'steam', username: username

    when /\"([^\<]+.*) disconnected \(reason \"(.+)\"/
      username, slot, account = parse_connected_user($1)
      event 'player_disconnected',
        account: account.to_i, account_type: 'steam', username: username,
        reason: $2

    # no STEAM_ID
    when /^Client "(\w+)" connected \(([\d\.:]+)\).$/
      username, address = $1, $2
      event 'player_connected',
        username: username, address: address

    when /^Dropped (\w+) from server \(([^\)]+)\)$/
      event 'player_disconnected', username: $1, reason: $2

    when /\"([^\<]+).* say (.+)/
      event 'chat', username: $1, msg: $2.gsub(/^"|"?$/, '')

    when /^Sending CMsgGameServerMatchmakingStatus/
      event 'started', msg: line

    when /^hostname: /
      @listing = true
      @user_count = nil
      @users = Set.new
      nil

    else
      event 'info', msg: line.strip
    end
  end

  def emit_players_list
    if @user_count == @users.size
      @listing = false
      event 'players_list', account_type: 'steam', accounts: @users.to_a
    end
  end

  def process_list_line(line)
    case line
    when /^players\s+:\s+(\d+)\s+\(\d+ max\)$/
      @user_count = $1.to_i
      nil

    when /#\s+\d+\s+"([^"]+)"\s+(STEAM[^ ]+)/
      @users.add(SteamID.new($2).to_i)
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
