defmodule MessagingWeb.Swagger.NotificationSwagger do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Notification:
        swagger_schema do
          title("Notification")
          description("A user notification")

          properties do
            id(:string, "Notification ID", required: true)
            user_id(:string, "User ID who receives the notification", required: true)
            title(:string, "Notification title", required: true)
            message(:string, "Notification message/content", required: true)

            type(:string, "Notification type",
              enum: ["info", "warning", "error", "success", "invite", "message"]
            )

            is_read(:boolean, "Whether the notification has been read", default: false)
            metadata(:object, "Additional notification metadata")
            created_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Last update timestamp", format: :datetime)
          end
        end,
      Notifications:
        swagger_schema do
          title("Notifications")
          description("A paginated collection of notifications")

          properties do
            data(:array, "List of notifications", items: Schema.ref(:Notification))
            page(:integer, "Current page number")
            page_size(:integer, "Number of items per page")
            total(:integer, "Total number of notifications")
            total_pages(:integer, "Total number of pages")
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
