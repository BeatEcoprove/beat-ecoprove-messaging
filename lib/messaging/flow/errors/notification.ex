defmodule Messaging.Flow.Errors.Notification do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      notification_not_found:
        Flow.not_found(
          "Messaging.Notification.NotFound.Title",
          "Messaging.Notification.NotFound.Description"
        )
    }
  end
end
