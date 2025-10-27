defmodule MessagingWeb.Controllers.NotificationJSON do
  alias MessagingWeb.Controllers.Helpers

  def render("notifications.json", %{paginate: data}) do
    formatted_data =
      Map.update!(data, :data, fn notifications ->
        Enum.map(notifications, &format_notification/1)
      end)

    Helpers.decode_pagination(formatted_data)
  end

  def render("notification.json", %{notification: notification}),
    do: format_notification(notification)

  defp format_notification(notification) when is_struct(notification) do
    %{
      id: notification._id,
      title: notification.title,
      body: notification.body,
      metadata: %{
        actor_id: notification.metadata.actor_id,
        recipient_id: notification.metadata.recipient_id,
        reference_id: notification.metadata.reference_id,
        reference_type: notification.metadata.reference_type
      },
      read: notification.read,
      type: notification.type
    }
  end

  defp format_notification(notification) when is_map(notification) do
    %{
      id: notification["_id"],
      title: notification["title"],
      body: notification["body"],
      metadata: notification["metadata"],
      read: notification["read"],
      type: notification["type"]
    }
  end
end
