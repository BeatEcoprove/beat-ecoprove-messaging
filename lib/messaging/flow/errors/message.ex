defmodule Messaging.Flow.Errors.Message do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      message_not_found:
        Flow.not_found(
          "Messaging.Message.NotFound.Title",
          "Messaging.Message.NotFound.Description"
        )
    }
  end
end
