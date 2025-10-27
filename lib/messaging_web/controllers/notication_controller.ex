defmodule MessagingWeb.Controllers.NotificationController do
  use MessagingWeb, :controller
  use PhoenixSwagger

  alias MessagingWeb.Swagger.NotificationSwagger
  alias MessagingApp.Notifications
  alias MessagingWeb.Controllers.Helpers

  plug MessagingWeb.Plugs.RequireScope,
    resource: :notification,
    actions: [
      index: :view,
      show: :view
    ]

  def swagger_definitions, do: NotificationSwagger.swagger_definitions()

  swagger_path :index do
    get("/notifications")
    summary("List notifications")
    description("Get a paginated list of notifications for the current user")
    produces("application/json")

    parameter(:page, :query, :integer, "Page number", example: 1)
    parameter(:page_size, :query, :integer, "Number of items per page", example: 20)
    parameter(:is_read, :query, :boolean, "Filter by read status (optional)", required: false)

    parameter(:type, :query, :string, "Filter by notification type (optional)",
      required: false,
      enum: ["group"]
    )

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Notifications))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(403, "Forbidden - insufficient permissions", Schema.ref(:Error))
  end

  def index(conn = %{assigns: %{current_user: current_user}}, params) do
    opts = Helpers.build_pagination_opts(params)

    case Notifications.get_all_notifications(current_user.id, opts) do
      {:ok, paginated_data} ->
        conn
        |> put_status(:ok)
        |> render("notifications.json", paginate: paginated_data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :show do
    get("/notifications/{id}")
    summary("Get notification details")
    description("Get detailed information about a specific notification")
    produces("application/json")

    parameter(:id, :path, :string, "Notification ID", required: true, example: "notif123")

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Notification))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(403, "Forbidden - insufficient permissions", Schema.ref(:Error))
    response(404, "Notification not found", Schema.ref(:Error))
  end

  def show(conn, %{"id" => notification_id}) do
    case Notifications.get_notification(notification_id) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> render("notification.json", notification: message)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
