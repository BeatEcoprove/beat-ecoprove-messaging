defmodule Messaging.Broker.Events.Invite.CreateEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:id, :string)
    field(:group_id, :string)
    field(:inviter_id, :string)
    field(:invitee_id, :string)
    field(:token, :string)
    field(:status, :integer)
    field(:role, :integer)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:id, :group_id, :inviter_id, :invitee_id, :token, :status, :role])
    |> validate_required([:id, :group_id, :inviter_id, :invitee_id, :token, :status, :role])
    |> Helpers.validate_uuid(:id)
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:inviter_id)
    |> Helpers.validate_uuid(:invitee_id)
    |> validate_number(:status,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 5,
      message: "Messaging.Validation.InvalidInviteStatus.Description"
    )
    |> validate_number(:role,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1,
      message: "Messaging.Validation.InvalidRole.Description"
    )
  end

  def type, do: "invite_created"
end
