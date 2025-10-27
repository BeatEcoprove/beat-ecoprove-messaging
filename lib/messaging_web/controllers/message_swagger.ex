defmodule MessagingWeb.Swagger.MessageSwagger do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Message:
        swagger_schema do
          title("Message")
          description("A message in a group")

          properties do
            id(:string, "Message ID", required: true)
            group_id(:string, "Group ID", required: true)
            sender_id(:string, "User ID of the sender", required: true)
            sender_username(:string, "Username of the sender")
            content(:string, "Message content", required: true)
            message_type(:string, "Type of message", enum: ["text", "image", "file", "system"])

            attachments(:array, "Message attachments",
              items: %{
                type: :object,
                properties: %{
                  url: %{type: :string},
                  filename: %{type: :string},
                  size: %{type: :integer},
                  mime_type: %{type: :string}
                }
              }
            )

            is_edited(:boolean, "Whether the message has been edited", default: false)
            is_deleted(:boolean, "Whether the message has been deleted", default: false)
            reply_to_id(:string, "ID of the message being replied to")
            created_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Last update timestamp", format: :datetime)
          end
        end,
      Messages:
        swagger_schema do
          title("Messages")
          description("A paginated collection of messages")

          properties do
            data(:array, "List of messages", items: Schema.ref(:Message))
            page(:integer, "Current page number")
            page_size(:integer, "Number of items per page")
            total(:integer, "Total number of messages")
            total_pages(:integer, "Total number of pages")
            has_next(:boolean, "Whether there are more messages")
            has_prev(:boolean, "Whether there are previous messages")
          end
        end,
      Error:
        swagger_schema do
          title("Error")
          description("Error response")

          properties do
            error(:string, "Error message", required: true)
          end
        end
    }
  end
end
