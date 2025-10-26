defmodule MessagingApp.Messages.Queries.GetAllMessages do
  alias Messaging.Persistence.Repos.MessageRepo
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Persistence.Repos.GroupRepo

  def call(user_id, group_id, opts \\ []) do
    with {:ok, group} <- get_group(group_id),
         {:ok} <- get_member(user_id, group.id) do
      MessageRepo.get_all(group_id, opts)
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_member(member_id, group_id) do
    case MemberRepo.get_by_public_id(member_id, group_id) do
      nil ->
        {:error, :member_not_found}

      _member ->
        {:ok}
    end
  end

  def get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
