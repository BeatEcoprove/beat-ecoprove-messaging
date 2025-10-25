defmodule Messaging.Auth.UserPresence do
  use Phoenix.Presence,
    otp_app: :messaging,
    pubsub_server: Messaging.PubSub
end
