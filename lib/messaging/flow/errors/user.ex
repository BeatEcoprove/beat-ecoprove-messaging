defmodule Messaging.Flow.Errors.User do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      user_not_found:
        Flow.not_found(
          "User not found",
          "The user was not found or doesn't exist."
        )
    }
  end
end
