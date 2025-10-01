defmodule Messaging.Flow.Errors.Group do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      group_already_exists:
        Flow.conflict(
          "Failed to create group",
          "A group with that name already exists."
        ),
      group_not_found:
        Flow.not_found(
          "Group not Found",
          "The group you are looking for does not exist or may have been deleted."
        ),
      group_wrong_input:
        Flow.conflict(
          "Json failed",
          "Provide a valid json format for the input"
        )
    }
  end
end
