defmodule Messaging.Broker.Event do
  @derive Jason.Encoder
  @enforce_keys [:key, :payload, :event_type]

  @source "messaging_service"

  defstruct version: 1,
            key: nil,
            payload: %{},
            event_type: nil,
            metadata: %{source: @source},
            occurred_at: nil

  @type t :: %__MODULE__{
          version: integer(),
          key: String.t(),
          payload: map(),
          event_type: String.t(),
          occurred_at: DateTime.t() | nil,
          metadata: map()
        }
end

defprotocol Messaging.Broker.KafkaEvent do
  @spec to_event(t()) :: {:ok, Messaging.Broker.Event.t()} | {:error, Ecto.Changeset.t()}
  def to_event(struct)
end
