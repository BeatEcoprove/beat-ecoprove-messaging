defmodule Messaging.Broker.EventFactory do
  require Logger

  alias Messaging.Broker.Events

  @events %{
    "profile_created" => Events.ProfileCreatedEvent,

    # invites
    "invite_created" => Events.Invite.CreateEvent,

    # messagees
    "text_message" => Events.Messages.MessageText,
    "borrow_message" => Events.Messages.MessageBorrow,

    # notifications
    "notify_invite_created" => Events.Notifications.CreateInvite
  }

  def build_event(%{"event_type" => event_type, "payload" => payload} = _data) do
    case Map.fetch(@events, event_type) do
      {:ok, module} ->
        struct = struct(module)
        changeset = module.changeset(struct, payload)

        if changeset.valid? do
          {:ok, Ecto.Changeset.apply_changes(changeset)}
        else
          Logger.info("event not valid, #{inspect(changeset)}")
          {:error, changeset}
        end

      :error ->
        Logger.info("Recive event, but will be ignored, #{inspect(event_type)}")
        {:error, {:unknown_event_type, event_type}}
    end
  end
end
