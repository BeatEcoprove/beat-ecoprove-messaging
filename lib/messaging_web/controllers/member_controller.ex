defmodule MessagingWeb.Controllers.MemberController do
  use MessagingWeb, :controller
  use PhoenixSwagger

  alias MessagingWeb.Swagger.MemberSwagger

  plug MessagingWeb.Plugs.RequireScope,
    resource: :member,
    actions: [
      index: :view,
      show: :view
    ]

  def swagger_definitions, do: MemberSwagger.swagger_definitions()

  swagger_path :change_role do
    post("/members/change-role")
    summary("Change member role")
    description("Change a member's role in a group. Requires appropriate permissions.")
    produces("application/json")
    consumes("application/json")

    parameter(:body, :body, Schema.ref(:ChangeRoleInput), "Role change parameters",
      required: true
    )

    security([%{Bearer: []}])

    response(200, "Role changed successfully", Schema.ref(:ChangeRoleResponse))
    response(400, "Invalid input", Schema.ref(:Error))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(403, "Forbidden - insufficient permissions", Schema.ref(:Error))
    response(404, "Group or member not found", Schema.ref(:Error))
    response(422, "Unprocessable entity", Schema.ref(:Error))
  end

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

  swagger_path :kick do
    post("/members/kick")
    summary("Kick member from group")
    description("Remove a member from a group. Requires admin or moderator permissions.")
    produces("application/json")
    consumes("application/json")

    parameter(:body, :body, Schema.ref(:KickMemberInput), "Kick member parameters",
      required: true
    )

    security([%{Bearer: []}])

    response(200, "Member kicked successfully", Schema.ref(:KickMemberResponse))
    response(400, "Invalid input", Schema.ref(:Error))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(403, "Forbidden - insufficient permissions to kick this member", Schema.ref(:Error))
    response(404, "Group or member not found", Schema.ref(:Error))

    response(
      422,
      "Unprocessable entity - cannot kick yourself or group owner",
      Schema.ref(:Error)
    )
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
