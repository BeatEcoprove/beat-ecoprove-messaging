defmodule Messaging.Flow.Errors.Notification do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      notification_not_found:
        Flow.not_found(
          "Notification not found",
          "The notification was not found or doesn't exist."
        )
    }
  end
end
