defmodule Messaging.Flow.Errors.Member do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      member_fail_op:
        Flow.conflict(
          "Messaging.Member.FailOp.Title",
          "Messaging.Member.FailOp.Description"
        ),
      member_low_rate:
        Flow.conflict(
          "Messaging.Member.LowRate.Title",
          "Messaging.Member.LowRate.Description"
        ),
      member_c_change_self:
        Flow.conflict(
          "Messaging.Member.ChangeSelfRole.Title",
          "Messaging.Member.ChangeSelfRole.Description"
        ),
      member_not_found:
        Flow.not_found(
          "Messaging.Member.NotFound.Title",
          "Messaging.Member.NotFound.Description"
        )
    }
  end
end
