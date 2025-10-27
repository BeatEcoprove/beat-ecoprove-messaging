defmodule MessagingWeb.Controllers.NotificationController do
  use MessagingWeb, :controller

  alias MessagingApp.Notifications
  alias MessagingWeb.Controllers.Helpers

  plug MessagingWeb.Plugs.RequireScope,
    resource: :notification,
    actions: [
      index: :view,
      show: :view
    ]

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
