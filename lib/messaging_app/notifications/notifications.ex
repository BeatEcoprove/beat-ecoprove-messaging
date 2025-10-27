defmodule MessagingApp.Notifications do
  alias Messaging.Persistence.Repos.NotificationRepo

  def get_all_notifications(user_id, opts \\ []), do: NotificationRepo.get_all(user_id, opts)

  def get_notification(user_id), do: NotificationRepo.get(user_id)
end
