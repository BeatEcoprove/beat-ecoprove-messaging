defmodule MessagingWeb.AuthChannel do
  alias Messaging.Presence
  use MessagingWeb, :channel

  @impl true
  def join("auth:" <> userId, _payload, socket) do
    if authorized?(userId, socket) do
      send(self(), :after_join)
      {:ok, userId, socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    Presence.track_user(socket, %{
      online_at: :os.system_time(:milli_seconds)
    })

    {:noreply, socket}
  end

  @impl true
  def terminate(_reason, socket) do
    Presence.remove_user(socket)
    {:ok, socket}
  end

  @impl true
  def handle_in("refresh_tokens", %{"accessToken" => accessToken}, socket) do
    with {:ok, _} <- Messaging.Auth.verify_token(accessToken) do
      updated_user_data = %{socket.assigns.user_data | accessToken: accessToken}

      updated_socket = assign(socket, :user_data, updated_user_data)

      {:reply, {:ok, %{message: "renewed"}}, updated_socket}
    else
      {:error, reason} ->
        {:stop, {:error, reason}, socket}
    end
  end

  defp authorized?(userId, socket) do
    userData = socket.assigns.user_data
    userId == userData.id
  end
end
