defmodule Messaging.Broker.Handlers.Chat do
  alias Messaging.Broker.Events

  alias Messaging.Persistence.Schemas.Message
  alias Messaging.Persistence.Repos.MessageRepo

  def handle(%{payload: %Events.Messages.SendMessageEvent{} = event}) do
    message =
      case event.type do
        "text" ->
          Message.create_text(
            %{
              content: event.content,
              sender_id: event.sender_id,
              group_id: event.group_id
            },
            reply_to: event.reply_to,
            mentions: event.mentions
          )

        "borrow" ->
          Message.create_borrow(
            %{
              content: event.content,
              sender_id: event.sender_id,
              group_id: event.group_id,
              garment_id: event.garment_id
            },
            reply_to: event.reply_to,
            mentions: event.mentions
          )
      end

    case MessageRepo.create(message) do
      {:ok, message} ->
        broadcast_message(event.group_id, message)
        {:ok}

      {:error, error} ->
        IO.puts("ERROR TO SEND MESSAGE! #{inspect(error)}")
    end
  end

  defp broadcast_message(group_id, message = %Message{}) do
    base_payload = %{
      id: message._id |> BSON.ObjectId.encode!() |> Base.encode16(case: :lower),
      type: message.type,
      content: message.content,
      mentions: message.mentions || [],
      reply_to: message.reply_to,
      sender_id: message.metadata.sender_id,
      group_id: group_id,
      inserted_at: message.inserted_at
    }

    payload =
      case message.type do
        "text" ->
          base_payload

        "borrow" ->
          Map.merge(base_payload, %{
            borrowed_item: Map.get(message.data, "garment_id", nil)
          })

        _ ->
          base_payload
      end

    Phoenix.PubSub.broadcast(
      Messaging.PubSub,
      "group:#{group_id}",
      {:broadcast_message, "recived_message", payload}
    )
  end
end
