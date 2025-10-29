defmodule Messaging.Flow.Errors.Group do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      group_already_exists:
        Flow.conflict(
          "Messaging.Group.AlreadyExists.Title",
          "Messaging.Group.AlreadyExists.Description"
        ),
      group_not_found:
        Flow.not_found(
          "Messaging.Group.NotFound.Title",
          "Messaging.Group.NotFound.Description"
        ),
      group_wrong_input:
        Flow.conflict(
          "Messaging.Group.WrongInput.Title",
          "Messaging.Group.WrongInput.Description"
        ),
      group_not_authorized:
        Flow.conflict(
          "Messaging.Group.NotAuthorized.Title",
          "Messaging.Group.NotAuthorized.Description"
        )
    }
  end
end
