defmodule Messaging.Flow.Errors.Member do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      member_fail_op:
        Flow.conflict(
          "Operation failed",
          "Soemthing went wrong while trying..."
        ),
      member_low_rate:
        Flow.conflict(
          "Not enough members",
          "You are the only one on the group you can't kick yourself!"
        ),
      member_not_found:
        Flow.not_found(
          "Member not found",
          "The member was not found or doesn't exist."
        )
    }
  end
end
