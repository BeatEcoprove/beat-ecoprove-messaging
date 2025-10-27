defmodule Messaging.Auth.Group do
  alias Messaging.Persistence.Repos.{GroupRepo, MemberRepo}

  def verify_membership(user_id, group_id) do
    with {:ok, group} <- get_group(group_id),
         {:ok, member} <- get_member(user_id, group.id) do
      {:ok, %{group: group, member: member}}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_member(user_id, group_id) do
    case MemberRepo.get_by_public_id(user_id, group_id) do
      nil -> {:error, :member_not_found}
      member -> {:ok, member}
    end
  end

  defp get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil -> {:error, :group_not_found}
      group -> {:ok, group}
    end
  end
end
