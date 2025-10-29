defmodule Messaging.Flow.Errors.User do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      user_not_found:
        Flow.not_found(
          "Messaging.User.NotFound.Title",
          "Messaging.User.NotFound.Description"
        ),
      user_not_authorized: Flow.unauthorized()
    }
  end
end
