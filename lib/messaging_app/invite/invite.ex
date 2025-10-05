defmodule MessagingApp.Invite.Invite do
  alias MessagingApp.Invite.Commands.CreateInvite
  alias MessagingApp.Invite.Commands.AcceptInvite

  def create_invite(attr), do: CreateInvite.call(attr)
  def accept_invite(invitee_id, token), do: AcceptInvite.call(invitee_id, token)
end
