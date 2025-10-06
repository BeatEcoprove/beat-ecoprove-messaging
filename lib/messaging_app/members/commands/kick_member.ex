defmodule MessagingApp.Members.Commands.KickMember do
  alias Messaging.Persistence.Schemas.Group
  alias MessagingApp.Members.Inputs.KickMemberInput
  alias Messaging.Persistence.Repos.GroupRepo
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Broker.Events.KickMemberEvent
  alias Messaging.Broker.EventBus

  def call(input = %KickMemberInput{}) do
    with {:ok, group} <- get_group(input.group_id),
         true <- check_kick(group),
         {:ok, member} <- get_member(input.member_id, group.id),
         {:ok} <- kick(member),
         :ok <- send_kick_member_event(group, input.actor_id, member) do
      {:ok, member}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_kick(group) do
    with {:ok, count} <- Group.get_members_count(group),
         true <- count > 1 do
      true
    else
      false ->
        {:error, :member_low_rate}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp kick(member) do
    case MemberRepo.delete(member) do
      {:ok, _} ->
        {:ok}

      {:error, _} ->
        {:error, :member_fail_op}
    end

    {:ok}
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

  defp send_kick_member_event(group, actor_id, member) do
    EventBus.publish(
      :messaging_events,
      %KickMemberEvent{
        group_id: group.public_id,
        actor_id: actor_id,
        member_id: member.user.public_id
      }
    )
  end
end
