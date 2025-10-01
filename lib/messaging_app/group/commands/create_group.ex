defmodule MessagingApp.Group.Commands.CreateGroup do
  alias Messaging.Persistence.Repos.UserRepo
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Repo
  alias MessagingApp.Group.Inputs.CreateGroupInput

  alias Messaging.Persistence.Repos.GroupRepo

  def call(input = %CreateGroupInput{}) do
    with {:ok} <- group_exists?(input.name, input.creator.id),
         {:ok, group} <- create_group(input),
         :ok <- send_created_group_event(group) do
      {:ok, group}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp group_exists?(name, creator_id),
    do:
      GroupRepo.already_created?(name, creator_id)
      |> check_group_exists()

  defp check_group_exists(true), do: {:error, :group_already_exists}
  defp check_group_exists(false), do: {:ok}

  defp create_group(input = %CreateGroupInput{}) do
    IO.puts("Creating group with input: #{inspect(input.creator)}")

    Repo.transact(fn ->
      with {:ok, group} <-
             GroupRepo.create(%{
               name: input.name,
               description: input.description,
               creator_id: input.creator.id,
               is_public: input.is_public || false
             }),
           {:ok, create_user} =
             UserRepo.create(%{
               public_id: input.creator.id,
               email: input.creator.email,
               role: input.creator.role
             }),
           {:ok, _} <-
             MemberRepo.create(%{
               user_id: create_user.id,
               group_id: group.id
             }) do
        {:ok, group}
      else
        {:error, changeset} ->
          {:error, changeset}
      end
    end)
  end

  defp send_created_group_event(group = %Messaging.Persistence.Schemas.Group{}) do
    Messaging.Broker.EventBus.publish(
      :auth_events,
      %Messaging.Broker.Events.GroupCreatedEvent{
        group_id: group.public_id,
        creator_id: group.creator_id
      }
    )
  end
end
