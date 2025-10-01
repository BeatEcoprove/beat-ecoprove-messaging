defmodule Messaging.Broker.Kafka.EventDriver do
  defmacro __using__(_) do
    quote do
      @derive Jason.Encoder
      use Ecto.Schema
      import Ecto.Changeset

      @behaviour Messaging.Broker.Kafka.EventDriver

      defimpl Messaging.Broker.KafkaEvent, for: __MODULE__ do
        def to_event(event) do
          changeset = @for.changeset(struct(@for), Map.from_struct(event))

          if changeset.valid? do
            {:ok,
             %Messaging.Broker.Event{
               key: Map.get(event, :key, Ecto.UUID.generate()),
               payload: event,
               event_type: @for.type(),
               occurred_at: DateTime.utc_now()
             }}
          else
            {:error, changeset}
          end
        end
      end

      @before_compile Messaging.Broker.Kafka.EventDriver
    end
  end

  @callback changeset(event :: struct(), attrs :: map()) :: Ecto.Changeset.t()
  @callback type() :: String.t()

  defmacro __before_compile__(env) do
    unless Module.defines?(env.module, {:changeset, 2}, :def) do
      raise "#{env.module} must implement changeset/2 function"
    end

    unless Module.defines?(env.module, {:type, 0}, :def) do
      raise "#{env.module} must implement type/0 function"
    end

    :ok
  end
end
