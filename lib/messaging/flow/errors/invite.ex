defmodule Messaging.Flow.Errors.Invite do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      invite_not_found:
        Flow.not_found(
          "Messaging.Invite.NotFound.Title",
          "Messaging.Invite.NotFound.Description"
        ),
      invite_self:
        Flow.conflict(
          "Messaging.Invite.Self.Title",
          "Messaging.Invite.Self.Description"
        ),
      invite_expired:
        Flow.forbidden(
          "Messaging.Invite.Expired.Title",
          "Messaging.Invite.Expired.Description"
        ),
      invite_fail_accept:
        Flow.conflict(
          "Messaging.Invite.FailAccept.Title",
          "Messaging.Invite.FailAccept.Description"
        )
    }
  end
end
