defmodule Messaging.Broker.Events.UserCreatedEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:public_id, :string)
    field(:email, :string)
    field(:role, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:public_id, :email, :role])
    |> validate_required([:public_id, :email, :role])
    |> Helpers.validate_uuid(:public_id)
    |> Helpers.validate_email(:email)
  end

  def type, do: "user_created"
end
