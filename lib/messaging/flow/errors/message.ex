defmodule Messaging.Flow.Errors.Message do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      message_not_found:
        Flow.not_found(
          "Message not found",
          "The message was not found or doesn't exist."
        )
    }
  end
end
