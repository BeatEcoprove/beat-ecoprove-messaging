defmodule MessagingWeb.Controllers.MemberController do
  use MessagingWeb, :controller

  def kick(conn = %{assigns: %{current_user: current_user}}, %{
        "group_id" => group_id,
        "member_id" => member_id
      }) do
    case MessagingApp.Members.kick(group_id, current_user.id, member_id) do
      {:ok, member} ->
        conn
        |> put_status(:ok)
        |> render("kick.json", member: member)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
