defmodule Messaging.Broker.Handlers.Invite do
  alias Messaging.Broker.Events
  alias Messaging.Persistence.Repos.GroupRepo

  def handle(%{payload: %Events.Invite.CreateEvent{} = event}) do
    case get_group_name(event.group_id) do
      {:ok, group} ->
        Messaging.Broker.EventBus.publish(
          :notifications_events,
          %Messaging.Broker.Events.Notifications.CreateInvite{
            recipient_id: event.invitee_id,
            actor_id: event.inviter_id,
            group_id: event.group_id,
            group_name: group.name
          }
        )

      {:error, reason} ->
        IO.puts("Error gathering data to send notification #{inspect(reason)}")
    end
  end

  defp get_group_name(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
