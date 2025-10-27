defmodule Messaging.Broker.Handlers.Chat do
  alias Messaging.Broker.Events

  alias Messaging.Persistence.Schemas.Message
  alias Messaging.Persistence.Repos.MessageRepo

  def handle(%{payload: %Events.Messages.MessageText{} = event}) do
    dispatch_message(
      Message.create_text(
        %{
          content: event.content,
          sender_id: event.sender_id,
          group_id: event.group_id
        },
        reply_to: event.reply_to,
        mentions: event.mentions
      ),
      event.group_id
    )
  end

  def handle(%{payload: %Events.Messages.MessageBorrow{} = event}) do
    dispatch_message(
      Message.create_borrow(
        %{
          content: event.content,
          sender_id: event.sender_id,
          group_id: event.group_id,
          garment_id: event.garment_id
        },
        reply_to: event.reply_to,
        mentions: event.mentions
      ),
      event.group_id
    )
  end

  def dispatch_message(message, group_id) do
    case MessageRepo.create(message) do
      {:ok, message} ->
        broadcast(message, group_id)
        {:ok}

      {:error, error} ->
        IO.puts("ERROR TO SEND MESSAGE! #{inspect(error)}")
        {:error, error}
    end
  end

  defp broadcast(message = %Message{}, group_id) when message.type == "borrow" do
    payload = %{
      id: message._id |> BSON.ObjectId.encode!() |> Base.encode16(case: :lower),
      type: message.type,
      content: message.content,
      mentions: message.mentions || [],
      reply_to: message.reply_to,
      sender_id: message.metadata.sender_id,
      group_id: group_id,
      borrow_item: Map.get(message.data, "garment_id", nil),
      inserted_at: message.inserted_at
    }

    broadcast(payload, group_id)
  end

  defp broadcast(message = %Message{}, group_id) when message.type == "text" do
    payload = %{
      id: message._id |> BSON.ObjectId.encode!() |> Base.encode16(case: :lower),
      type: message.type,
      content: message.content,
      mentions: message.mentions || [],
      reply_to: message.reply_to,
      sender_id: message.metadata.sender_id,
      group_id: group_id,
      inserted_at: message.inserted_at
    }

    broadcast(payload, group_id)
  end

  defp broadcast(payload, group_id) do
    Phoenix.PubSub.broadcast(
      Messaging.PubSub,
      "group:#{group_id}",
      {:broadcast_message, "recived_message", payload}
    )

    {:ok}
  end
end
