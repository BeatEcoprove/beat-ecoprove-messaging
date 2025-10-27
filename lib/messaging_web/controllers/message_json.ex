defmodule MessagingWeb.Controllers.MessageJSON do
  alias MessagingWeb.Controllers.Helpers

  def render("messages.json", %{paginate: data}) do
    formatted_data =
      Map.update!(data, :data, fn messages ->
        Enum.map(messages, &format_message/1)
      end)

    Helpers.decode_pagination(formatted_data)
  end

  def render("message.json", %{message: message}), do: format_message(message)

  defp format_message(message) when is_struct(message) do
    %{
      id: message._id,
      payload: %{
        content: message.content,
        mentions: message.mentions,
        reply_to: message.reply_to
      },
      metadata: Map.from_struct(message.metadata),
      type: message.type
    }
  end

  defp format_message(message) when is_map(message) do
    %{
      id: message["_id"],
      payload: %{
        content: message["content"],
        mentions: Map.get(message, "mentions", []),
        reply_to: Map.get(message, "reply_to")
      },
      metadata: message["metadata"],
      type: message["type"]
    }
  end
end
