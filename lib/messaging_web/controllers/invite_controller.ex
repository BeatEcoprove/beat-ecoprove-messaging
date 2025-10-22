defmodule MessagingWeb.Controllers.InviteController do
  use MessagingWeb, :controller

  alias MessagingApp.Invite.Inputs.CreateInviteInput

  plug MessagingWeb.Plugs.RequireScope,
    resource: :invite

  @doc """
  Send invite to a user
  """
  def create(conn = %{assigns: %{current_user: current_user}}, %{
        "id" => group_id,
        "payload" => payload
      }) do
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
