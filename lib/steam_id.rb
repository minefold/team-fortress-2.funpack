class SteamID
  BASE_64 = 0x0110000100000000

  def initialize(representation)
    if representation =~ /^STEAM/
      x, y, z = representation.split(':').map(&:to_i)

      @int64 = (z * 2) + BASE_64 + y
    else
      @int64 = Integer(representation)
    end
  end

  def to_i
    @int64
  end

  def to_s
    w = @int64 - BASE_64
    parity = w % 2
    "STEAM_0:#{parity}:#{w / 2}"
  end
end