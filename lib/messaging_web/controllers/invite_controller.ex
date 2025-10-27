defmodule MessagingWeb.Controllers.InviteController do
  use MessagingWeb, :controller
  use PhoenixSwagger

  alias MessagingWeb.Swagger.InviteSwagger
  alias MessagingApp.Invite.Inputs.CreateInviteInput

  plug MessagingWeb.Plugs.RequireScope,
    resource: :invite

  def swagger_definitions, do: InviteSwagger.swagger_definitions()

  swagger_path :create do
    post("/groups/{id}/invites")
    summary("Send group invite")
    description("Send an invitation to a user to join a group")
    produces("application/json")
    consumes("application/json")

    parameter(:id, :path, :string, "Group ID", required: true, example: "group456")
    parameter(:body, :body, Schema.ref(:CreateInviteInput), "Invite parameters", required: true)

    security([%{Bearer: []}])

    response(200, "Invite sent successfully", Schema.ref(:Invite))
    response(400, "Invalid input", Schema.ref(:Error))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(404, "Group or user not found", Schema.ref(:Error))
    response(422, "Unprocessable entity", Schema.ref(:Error))
  end

  @doc """
  Send invite to a user
  """
  def create(
        conn = %{assigns: %{current_user: current_user}},
        %{
          "id" => group_id
        } = payload
      ) do
    input = %CreateInviteInput{
      group_id: group_id,
      inviter_id: current_user.id,
      invitee_id: payload["invitee_id"],
      role: payload["role"]
    }

    case MessagingApp.Invite.Invite.create_invite(input) do
      {:ok, invite} ->
        conn
        |> put_status(:ok)
        |> render("invite.json", invite: invite)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :accept do
    post("/invites/accept")
    summary("Accept group invite")
    description("Accept a group invitation using the invitation token")
    produces("application/json")
    consumes("application/json")

    parameter(:body, :body, Schema.ref(:AcceptInviteInput), "Accept invite parameters",
      required: true
    )

    security([%{Bearer: []}])

    response(200, "Invite accepted successfully", Schema.ref(:Invite))
    response(400, "Invalid token", Schema.ref(:Error))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(404, "Invite not found", Schema.ref(:Error))
    response(422, "Unprocessable entity - invite already processed", Schema.ref(:Error))
  end

  def accept(conn = %{assigns: %{current_user: current_user}}, %{
        "token" => token
      }) do
    case MessagingApp.Invite.Invite.accept_invite(current_user.id, token) do
      {:ok, invite} ->
        conn
        |> put_status(:ok)
        |> render("invite.json", invite: invite)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :decline do
    post("/invites/decline")
    summary("Decline group invite")
    description("Decline a group invitation using the invitation token")
    produces("application/json")
    consumes("application/json")

    parameter(:body, :body, Schema.ref(:DeclineInviteInput), "Decline invite parameters",
      required: true
    )

    security([%{Bearer: []}])

    response(200, "Invite declined successfully", Schema.ref(:Invite))
    response(400, "Invalid token", Schema.ref(:Error))
    response(401, "Unauthorized", Schema.ref(:Error))
    response(404, "Invite not found", Schema.ref(:Error))
    response(422, "Unprocessable entity - invite already processed", Schema.ref(:Error))
  end

  def decline(conn = %{assigns: %{current_user: current_user}}, %{
        "token" => token
      }) do
    case MessagingApp.Invite.Invite.decline_invite(current_user.id, token) do
      {:ok, invite} ->
        conn
        |> put_status(:ok)
        |> render("invite.json", invite: invite)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
