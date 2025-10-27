defmodule Messaging.Broker.EventFactory do
  alias Messaging.Broker.Events

  @events %{
    "user_created" => Events.UserCreatedEvent,

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
          {:error, changeset}
        end

      :error ->
        {:error, {:unknown_event_type, event_type}}
    end
  end
end
