require 'json'
require 'time'
require 'set'

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
      event 'players_list', usernames: @users.to_a
    end
  end

  def process_list_line(line)
    case line
    when /^players\s+:\s+(\d+)\s+\(\d+ max\)$/
      @user_count = $1.to_i
      nil

    when /#\s+\d+\s+"([^"]+)"\s+(STEAM[^ ]+)/
      @users.add($2)
      emit_players_list
    else
      
      emit_players_list
    end
  end

  # chrsllyd<2><STEAM_0:1:123456><>
  def parse_connected_user(user)
    user =~ /([^<]+)<(\d+)><([^>]+)>/
    [$1, $2, $3]
  end


  def event(event, options = {})
    {
      ts: Time.now.utc.iso8601,
      event: event,
    }.merge(options)
  end
end
