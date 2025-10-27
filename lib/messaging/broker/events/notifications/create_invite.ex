defmodule Messaging.Broker.Events.Notifications.CreateInvite do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:recipient_id, :string)
    field(:actor_id, :string)
    field(:group_id, :string)
    field(:group_name, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [
      :recipient_id,
      :actor_id,
      :group_id,
      :group_name
    ])
    |> validate_required([:recipient_id, :actor_id, :group_id, :group_name])
    |> Helpers.validate_uuid(:recipient_id)
    |> Helpers.validate_uuid(:actor_id)
    |> Helpers.validate_uuid(:group_id)
  end

  def type, do: "notify_invite_created"
end
