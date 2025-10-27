defmodule MessagingApp.Group do
  alias MessagingApp.Group.Commands.UpdateGroup
  alias Messaging.Persistence.Repos.GroupRepo
  alias MessagingApp.Group.Commands.CreateGroup

  def create_group(attr), do: CreateGroup.call(attr)

  def delete_group(attr) do
    with {:ok, group} <-
           get_details(attr),
         {:ok, deleted_group} <- GroupRepo.delete(group) do
      {:ok, deleted_group}
    else
      {:error, changeset} ->
        {:error, changeset}
    end
  end

  def update_group(%{id: id, payload: payload}), do: UpdateGroup.call(id, payload)

  def get_all(%{user_id: user_id}), do: GroupRepo.get_belonging_groups(user_id)

  def get_details(%{group_id: group_id}) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
