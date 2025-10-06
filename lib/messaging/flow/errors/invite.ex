defmodule Messaging.Flow.Errors.Invite do
  @behaviour Messaging.Flow.Base
  alias Messaging.Flow

  def register() do
    %{
      invite_not_found:
        Flow.not_found(
          "Invite not found",
          "The invite you are looking for does not exist or may have been expired."
        ),
      invite_self:
        Flow.conflict(
          "Failed to invite",
          "You can't invite yourself to the group"
        ),
      invite_expired:
        Flow.forbidden(
          "Invite Expired",
          "The invite you are looking is expired"
        ),
      invite_fail_accept:
        Flow.conflict(
          "Invitation Failed",
          "Something went wrong, while processing invite request, please try again later"
        )
    }
  end
end
