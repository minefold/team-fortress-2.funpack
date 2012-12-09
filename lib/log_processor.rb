require 'json'
require 'time'
require 'set'

class LogProcessor
  def initialize(pid, out)
    @pid = pid
    @out = out
    @listing = false

    @users = Set.new
  end

  def process_line(line)
    line.gsub!(/L [\d\/]+ - [\d:]+ /, '')
    # puts line
    # TODO
    # stopping
    # settings_changed
    # fatal_error - failed to start, port bound?
    # players

    if @listing
      process_list_line(line)
    else
      process_regular_line(line)
    end
  end

  def process_regular_line(line)
    case line
    when /^\"(.*)\" entered the game$/
      # username looks like this: chrsllyd<2><STEAM_0:1:123456><>
      # we want the STEAM_X:Y:Z part
      matches = $1.scan(/<([^>]+)>/)
      slot = matches[0][0]
      userid = matches[1][0]
      @users.add(userid)

      event 'player_connected', username: userid

    when /\"([^\<]+)(.*) disconnected \(reason \"(.+)\"/
      matches = $1.scan(/<([^>]+)>/)
      userid = matches[1][0]
      @users.delete(userid)
      event 'player_disconnected', username: $1, reason: $2

    when /\"([^\<]+).* say (.+)/
      event 'chat', username: $1, msg: $2.gsub(/^"|"?$/, '')

    when /^Connection to game coordinator established\.$/
      event 'started'

    when '<slot:userid:\"name\">'
      @listing = true

    else
      event 'info', msg: line.strip
    end

    # if !@started and port_bound?(@port)
    #   @started = true
    #   event 'started'
    # end
  end

  def players_list
    event 'players_list', usernames: @users.to_a
  end

  def process_list_line(line)
    case line
    when /^\d+ users/
      @listing = false

    when /:/
      slot = line.split(':')[1]


    end
  end

  def event(event, options = {})
    @out.puts JSON.dump({
      ts: Time.now.utc.iso8601,
      event: event,
      pid: @pid
    }.merge(options))
  end

  # def port_bound?(port)
  #   `netstat -lntp 2> /dev/null | grep :#{port} | wc -l`.strip.to_i > 0
  # end
end
