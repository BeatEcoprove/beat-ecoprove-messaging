defmodule MessagingApp.Members do
  alias MessagingApp.Members.Commands.KickMember
  alias MessagingApp.Members.Inputs.KickMemberInput
  alias MessagingApp.Members.Commands.ChangeRole
  alias MessagingApp.Members.Inputs.ChangeRoleInput

  def kick(group_id, actor_id, member_id),
    do:
      KickMember.call(%KickMemberInput{
        group_id: group_id,
        actor_id: actor_id,
        member_id: member_id
      })

  def change_role(group_id, current_user, role),
    do:
      ChangeRole.call(%ChangeRoleInput{
        group_id: group_id,
        current_user: current_user,
        role: role
      })
end
