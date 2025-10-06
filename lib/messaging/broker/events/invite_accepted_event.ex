defmodule Messaging.Broker.Events.InviteAcceptedEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:invite_id, :string)
    field(:group_id, :string)
    field(:invitee_id, :string)
    field(:role, :integer)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:invite_id, :group_id, :invitee_id, :role])
    |> validate_required([:invite_id, :group_id, :invitee_id, :role])
    |> Helpers.validate_uuid(:invite_id)
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:invitee_id)
    |> validate_number(:role,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1,
      message: "Role must be the range of [0..1], (member/admin)"
    )
  end

  def type, do: "invite_accepted"
end
