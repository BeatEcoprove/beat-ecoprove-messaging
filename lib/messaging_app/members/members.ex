defmodule MessagingApp.Members do
  alias MessagingApp.Members.Commands.KickMember
  alias MessagingApp.Members.Inputs.KickMemberInput

  def kick(group_id, actor_id, member_id),
    do:
      KickMember.call(%KickMemberInput{
        group_id: group_id,
        actor_id: actor_id,
        member_id: member_id
      })
end
