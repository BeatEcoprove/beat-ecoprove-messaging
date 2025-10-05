defmodule MessagingWeb.Controllers.InviteJSON do
  alias Messaging.Persistence.Schemas.Invite

  def render("invite.json", %{invite: invite = %Invite{}}) do
    %{
      id: invite.public_id,
      group_id: invite.group.public_id,
      inviter_id: invite.inviter.public_id,
      invitee_id: invite.invitee.public_id,
      role: conv_role(invite.role),
      status: conv_status(invite.status),
      token: invite.token
    }
  end

  defp conv_status(status), do: Invite.Status.get_status(status)
  defp conv_role(role), do: Invite.Role.get_role(role)
end
