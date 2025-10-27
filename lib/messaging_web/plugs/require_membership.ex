defmodule MessagingWeb.Plugs.RequireMembership do
  import Plug.Conn

  alias MessagingWeb.Controllers.ErrorController
  alias Messaging.Auth.Group

  def init(opts), do: opts

  def call(conn, _opts) do
    group_id = conn.params["group_id"]
    user_id = conn.assigns.current_user.id

    case Group.verify_membership(user_id, group_id) do
      {:ok, result} ->
        conn
        |> assign(:group, result.group)
        |> assign(:member, result.member)
        |> assign(:membership_verified, true)

      {:error, error} ->
        conn
        |> ErrorController.call({:error, error})
        |> halt()
    end
  end
end
