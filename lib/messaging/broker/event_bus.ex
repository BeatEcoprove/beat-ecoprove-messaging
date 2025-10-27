defmodule Messaging.Broker.EventBus do
  @behaviour :brod_group_subscriber_v2

  alias Messaging.Broker.Exceptions
  alias Messaging.Broker.KafkaEvent
  alias Messaging.Broker.Kafka.Publisher

  @topics %{
    :auth_events => "auth_events",

    # generic events and especific events
    :messaging_events => "messaging_events",
    :email_events => "messaging_events_email",
    :chat_events => "messaging_chat_events",
    :notifications_events => "messaging_notifications_events"
  }

  def child_spec(_arg) do
    config = %{
      client: :kafka_client,
      group_id: "message_consumer",
      topics: Map.values(@topics),
      cb_module: __MODULE__,
      consumer_config: [{:begin_offset, :earliest}],
      init_data: [],
      message_type: :message_set,
      group_config: [
        offset_commit_policy: :commit_to_kafka_v2,
        offset_commit_interval_seconds: 5,
        rejoin_delay_seconds: 60,
        reconnect_cool_down_seconds: 60
      ]
    }

    %{
      id: __MODULE__,
      start: {:brod_group_subscriber_v2, :start_link, [config]},
      type: :worker,
      restart: :temporary,
      shutdown: 5000
    }
  end

  @impl :brod_group_subscriber_v2
  def init(_group_id, _init_data), do: {:ok, []}

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

  def parse_event(json_event) do
    with {:ok, parsed_event} <- Jason.decode(json_event),
         {:ok, payload} <- Messaging.Broker.EventFactory.build_event(parsed_event) do
      event = %Messaging.Broker.Event{
        version: parsed_event["version"],
        key: parsed_event["key"],
        payload: payload,
        event_type: parsed_event["event_type"],
        occurred_at: parsed_event["occurred_at"],
        metadata: parsed_event["metadata"]
      }

      {:ok, event}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  @impl :brod_group_subscriber_v2
  def handle_message(
        {:kafka_message_set, topic, _partition, _count, messages},
        state
      ) do
    Enum.each(messages, fn {:kafka_message, _offset, _key, json_string, _type, _timestamp,
                            _metadata} ->
      case parse_event(json_string) do
        {:ok, event} ->
          dispatch_event(topic, event)

        {:error, reason} ->
          IO.puts("Error: #{inspect(reason)}")
      end
    end)

    {:ok, :commit, state}
  end

  def dispatch_event("auth_events", event), do: Messaging.Broker.Handlers.Auth.handle(event)

  def dispatch_event("messaging_events", event),
    do: Messaging.Broker.Handlers.Invite.handle(event)

  def dispatch_event("messaging_chat_events", event),
    do: Messaging.Broker.Handlers.Chat.handle(event)

  def dispatch_event("messaging_notifications_events", event),
    do: Messaging.Broker.Handlers.Notification.handle(event)

  def dispatch_event(topic, event),
    do: IO.puts("Recived by: #{inspect(topic)} -> #{inspect(event)}")
end
