defmodule Messaging.Broker.Events.GroupCreatedEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:group_id, :string)
    field(:creator_id, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:group_id, :creator_id])
    |> validate_required([:group_id, :creator_id])
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:creator_id)
  end

  def type, do: "group_created"
end
