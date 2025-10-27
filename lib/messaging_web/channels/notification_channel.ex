defmodule MessagingWeb.NotificationChannel do
  use MessagingWeb, :channel

  @impl true
  def join("notification:" <> userId, _payload, socket) do
    user = socket.assigns.user

    case userId == user.id do
      false ->
        {:error, :user_not_authorized}

      true ->
        {:ok, socket}
    end
  end

  @impl true
  def handle_info({:broadcast_notification, event, payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  # read notification - catch [mark as read]
end
