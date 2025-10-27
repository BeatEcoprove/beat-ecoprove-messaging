defmodule Messaging.Broker.Handlers.Notification do
  alias Messaging.Persistence.Schemas.Notification
  alias Messaging.Persistence.Repos.NotificationRepo
  alias Messaging.Broker.Events

  @channel "notification"

  def handle(%{payload: %Events.Notifications.CreateInvite{} = event}) do
    dispatch_notification(
      Notification.create_invite(%{
        recipient_id: event.recipient_id,
        actor_id: event.actor_id,
        group_id: event.group_id,
        group_name: event.group_name
      })
    )
  end

  defp dispatch_notification(notification) do
    case NotificationRepo.create(notification) do
      {:ok, notification} ->
        broadcast(notification)

      {:error, error} ->
        IO.puts("ERROR TO SEND notification! #{inspect(error)}")
        {:error, error}
    end
  end

  defp broadcast(notification) do
    payload = %{
      id: notification._id |> BSON.ObjectId.encode!() |> Base.encode16(case: :lower),
      title: notification.title,
      body: notification.body,
      metadata: %{
        group_id: Map.get(notification.data, "group_id", nil),
        actor_id: notification.metadata.actor_id,
        inserted_at: notification.inserted_at
      },
      read: notification.read,
      type: notification.type
    }

    Phoenix.PubSub.broadcast(
      Messaging.PubSub,
      "#{@channel}:#{notification.metadata.recipient_id}",
      {:broadcast_notification, "send_notification", payload}
    )

    {:ok}
  end
end
