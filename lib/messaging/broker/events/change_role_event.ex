defmodule Messaging.Broker.Events.ChangeRoleEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:group_id, :string)
    field(:actor_id, :string)
    field(:member_id, :string)
    field(:role, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:group_id, :actor_id, :member_id, :role])
    |> validate_required([:group_id, :actor_id, :member_id, :role])
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:actor_id)
    |> Helpers.validate_uuid(:member_id)
    |> validate_inclusion(:role, ["member", "moderator", "admin"])
  end

  def type, do: "change_role"
end
