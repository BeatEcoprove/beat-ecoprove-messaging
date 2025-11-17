defmodule Messaging.Broker.Events.ProfileCreatedEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:auth_id, :string)
    field(:profile_id, :string)
    field(:display_name, :string)
    field(:role, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:auth_id, :profile_id, :display_name, :role])
    |> validate_required([:auth_id, :profile_id, :display_name, :role])
    |> Helpers.validate_uuid(:auth_id)
    |> Helpers.validate_uuid(:profile_id)
  end

  def type, do: "profile_created"
end
