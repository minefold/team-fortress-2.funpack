class SteamID
  BASE_64 = 0x0110000100000000

  def initialize(representation)
    x, y, z = representation.split(':').map(&:to_i)

    @int64 = (z * 2) + BASE_64 + y
  end

  def to_i
    @int64
  end
end