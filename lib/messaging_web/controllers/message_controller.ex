defmodule MessagingWeb.Controllers.MessageController do
  use MessagingWeb, :controller

  alias MessagingApp.Messages
  alias MessagingWeb.Controllers.Helpers

  plug MessagingWeb.Plugs.RequireMembership

  plug MessagingWeb.Plugs.RequireScope,
    resource: :message,
    actions: [
      index: :view,
      show: :view
    ]

  def index(conn = %{assigns: %{group: group}}, params) do
    opts = Helpers.build_pagination_opts(params)

    case Messages.get_all_messages(group.public_id, opts) do
      {:ok, paginated_data} ->
        conn
        |> put_status(:ok)
        |> render("messages.json", paginate: paginated_data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def show(conn, %{"id" => message_id}) do
    case Messages.get(message_id) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> render("message.json", message: message)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
