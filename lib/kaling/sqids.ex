defmodule Kaling.Hashing do
  @settings Hashids.new()

  def encode(number), do: Hashids.encode(@settings, number)
  def decode(hash), do: Hashids.decode(@settings, hash)
end
