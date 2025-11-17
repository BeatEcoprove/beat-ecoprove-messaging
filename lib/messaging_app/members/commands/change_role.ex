defmodule MessagingApp.Members.Commands.ChangeRole do
  alias MessagingApp.Members.Inputs.ChangeRoleInput

  alias Messaging.Persistence.Repos.GroupRepo
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Broker.Events.ChangeRoleEvent
  alias Messaging.Broker.EventBus

  def call(input = %ChangeRoleInput{}) do
    with {:ok, group} <- get_group(input.group_id),
         {:ok, member} <- get_member(input.current_user.id, group.id),
         {:ok} <- check_change_role(member.user.profile_id, input.current_user.id),
         :ok <-
           update_role(group, input.current_user, member, input.role) do
      {:ok, member, input.role}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_change_role(member_id, current_user_id) do
    if member_id != current_user_id do
      {:ok}
    else
      {:error, :member_c_change_self}
    end
  end

  defp update_role(group, current_user, member, role) do
    EventBus.publish(
      :messaging_events,
      %ChangeRoleEvent{
        group_id: group.public_id,
        actor_id: current_user.id,
        member_id: member.user.profile_id,
        role: role
      }
    )
  end

  defp get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) |> GroupRepo.preload() do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end

  defp get_member(member_id, group_id) do
    case MemberRepo.get_by_public_id(member_id, group_id) |> MemberRepo.preload() do
      nil ->
        {:error, :member_not_found}

      member ->
        {:ok, member}
    end
  end
end
