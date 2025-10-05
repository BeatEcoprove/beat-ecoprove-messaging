defmodule Messaging.Redis.Keys.InviteKey do
  @behaviour Messaging.Redis.Key

  @prefix "invite:"
  @exp 3600

  def key(value), do: @prefix <> value
  def exp(), do: @exp
end
