defmodule MessagingWeb.Controllers.MemberController do
  use MessagingWeb, :controller

  def change_role(conn = %{assigns: %{current_user: current_user}}, %{
        "group_id" => group_id,
        "name" => role
      }) do
    case MessagingApp.Members.change_role(group_id, current_user, role) do
      {:ok, member, role} ->
        conn
        |> put_status(:ok)
        |> render("change_role.json", member: member, role: role)

      {:error, reason} ->
        {:error, reason}
    end
  end

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
