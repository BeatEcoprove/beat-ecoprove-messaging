defmodule Messaging.Broker.Events.Messages.SendMessageEvent do
  use Messaging.Broker.Kafka.EventDriver

  alias Messaging.Persistence.Helpers

  @primary_key false
  embedded_schema do
    field(:group_id, :string)
    field(:sender_id, :string)
    field(:garment_id, :string)
    field(:content, :string)
    field(:reply_to, :string)
    field(:mentions, {:array, :string}, default: [])
    field(:type, :string)
  end

  def changeset(event, attrs) do
    event
    |> cast(attrs, [:group_id, :sender_id, :garment_id, :content, :type, :mentions, :reply_to])
    |> validate_required([:group_id, :sender_id, :content])
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:sender_id)
  end

  def type, do: "send_message"
end
