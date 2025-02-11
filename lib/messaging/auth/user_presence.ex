defmodule Messaging.Presence do
  use Phoenix.Presence,
    otp_app: :messaging,
    pubsub_server: Messaging.PubSub

  @topic "auth"

  def track_user(socket, metadata) do
    user_data = socket.assigns.user_data
    metadata = Map.put(metadata, :accessToken, user_data.accessToken)

    track(self(), @topic, get_key(user_data.id), metadata)
  end

  def remove_user(socket) do
    user_data = socket.assigns.user_data
    untrack(self(), @topic, get_key(user_data.id))
  end

  defp get_key(id) do
    "#{@topic}:#{id}"
  end

  def list_online_users do
    list(@topic)
  end
end
