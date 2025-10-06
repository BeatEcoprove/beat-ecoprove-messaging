defmodule MessagingApp.Invite.Invite do
  alias MessagingApp.Invite.Commands.CreateInvite
  alias MessagingApp.Invite.Commands.AcceptInvite
  alias MessagingApp.Invite.Commands.DeclineInvite

  def create_invite(attr), do: CreateInvite.call(attr)
  def accept_invite(invitee_id, token), do: AcceptInvite.call(invitee_id, token)
  def decline_invite(invitee_id, token), do: DeclineInvite.call(invitee_id, token)
end
