require 'json'
require 'time'
require 'set'

class LogProcessor
  def initialize
    @listing = false

    @users = Set.new
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
    when /^\"([^\<]+.*)\" entered the game$/
      username, slot, account = parse_connected_user($1)
      event 'player_connected',
        account: account, account_type: 'steam', username: username

    when /^Client "(\w+)" connected \(([\d\.:]+)\).$/
      username, address = $1, $2
      event 'player_connected',
        username: username, address: address

    when /\"([^\<]+.*) disconnected \(reason \"(.+)\"/
      username, slot, account = parse_connected_user($1)
      event 'player_disconnected',
        account: account, account_type: 'steam', username: username,
        reason: $2

    when /^Dropped (\w+) from server \(([^\)]+)\)$/
      event 'player_disconnected', username: $1, reason: $2

    when /\"([^\<]+).* say (.+)/
      event 'chat', username: $1, msg: $2.gsub(/^"|"?$/, '')

    when /^Sending CMsgGameServerMatchmakingStatus/
      event 'started', msg: line

    when %Q{<slot:userid:"name">}
      @listing = true
      nil

    else
      event 'info', msg: line.strip
    end

    # if !@started and port_bound?(@port)
    #   @started = true
    #   event 'started'
    # end
  end

  def process_list_line(line)
    case line
    when /^\d+ users/
      @listing = false
      event 'players_list', usernames: @users.to_a

    when /:/
      slot, userid, username = line.split(':')
      @users.add(username.gsub(/^"|"$/, ''))
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

  # def port_bound?(port)
  #   `netstat -lntp 2> /dev/null | grep :#{port} | wc -l`.strip.to_i > 0
  # end
end
