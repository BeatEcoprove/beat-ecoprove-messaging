defmodule Messaging.Broker.EventBus do
  alias Messaging.Broker.Exceptions
  alias Messaging.Broker.KafkaEvent
  alias Messaging.Broker.Kafka.Publisher

  @topics %{
    :auth_events => "auth_events"
  }

  @spec publish(atom(), map()) :: :ok | {:error, any()}
  def publish(topic, event) when is_atom(topic) and is_struct(event) do
    with {:ok, topic_channel} <- Map.fetch(@topics, topic),
         {:ok, event = %Messaging.Broker.Event{}} <- KafkaEvent.to_event(event) do
      encoded_payload = Jason.encode!(event)

      Publisher.publish(topic_channel, event.key, encoded_payload)
    else
      {:error, changeset} ->
        raise Exceptions.EventPublishError,
          changeset: changeset,
          event: event

      :error ->
        raise Exceptions.TopicError, topics: Map.keys(@topics)
    end
  end
end
