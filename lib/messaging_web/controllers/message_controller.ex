defmodule MessagingWeb.Controllers.MessageController do
  use MessagingWeb, :controller

  alias MessagingApp.Messages
  alias MessagingWeb.Controllers.Helpers

  plug MessagingWeb.Plugs.RequireScope,
    # message:view // message:create
    resource: :member,
    actions: [
      index: :view,
      show: :view
    ]

  def index(conn = %{assigns: %{current_user: current_user}}, %{group_id: group_id} = params) do
    opts = Helpers.build_pagination_opts(params)

    case Messages.get_all_messages(current_user.id, group_id, opts) do
      {:ok, paginated_data} ->
        conn
        |> put_status(:ok)
        |> render("messages.json", paginate: paginated_data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  def show do
  end
end
