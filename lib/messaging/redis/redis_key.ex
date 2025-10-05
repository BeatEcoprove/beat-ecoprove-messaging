defmodule Messaging.Redis.Key do
  @callback key(any()) :: String.t()
end
