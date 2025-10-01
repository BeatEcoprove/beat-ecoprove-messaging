defmodule Messaging.Broker.Kafka.Publisher do
  @client :kafka_client

  def publish(topic, key, value) do
    case :brod.produce_sync(@client, topic, 0, key, value) do
      :ok ->
        :ok

      {:error, reason} ->
        IO.puts("Failed to publish message to #{topic}: #{inspect(reason)}")
        {:error, reason}
    end
  end
end
