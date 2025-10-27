defmodule MessagingApp.Invite.Commands.CreateInvite do
  alias Messaging.Repo
  alias Messaging.Persistence.Repos.InviteRepo
  alias Messaging.Persistence.Repos.UserRepo
  alias Messaging.Persistence.Repos.GroupRepo
  alias MessagingApp.Invite.Inputs.CreateInviteInput
  alias Messaging.Redis.Keys.InviteKey
  alias Messaging.Redis.RClient

  # TODO on token verify if the current user has access to invite others onto the group!
  def call(input = %CreateInviteInput{}) do
    with {:ok, group_ctx} <- get_group(input.group_id),
         {:ok, inviter} <- get_inviter(input.inviter_id),
         {:ok, invitee} <- get_invitee(input.invitee_id),
         {:ok} <- check_self_invitation(inviter.id, invitee.id),
         {:ok, invite} <- create_invite(group_ctx, inviter, invitee, input.role),
         :ok <- send_create_invite_event(invite) do
      {:ok, invite}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_self_invitation(inviter_id, invitee_id) do
    case inviter_id != invitee_id do
      true ->
        {:ok}

      false ->
        {:error, :invite_self}
    end
  end

  defp create_invite(group_ctx, inviter, invitee, role) do
    token = gen_token()

    Repo.transact(fn ->
      with {:ok, invite} <-
             InviteRepo.create(%{
               group_id: group_ctx.id,
               inviter_id: inviter.id,
               invitee_id: invitee.id,
               role: role,
               token: token
             }),
           :ok <- RClient.set(InviteKey.key(token), invite.public_id, InviteKey.exp()) do
        {:ok, invite}
      else
        {:error, changeset} ->
          {:error, changeset}
      end
    end)
  end

  defp get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end

  defp get_inviter(inviter_id) do
    case UserRepo.get_by_public_id(inviter_id) do
      nil ->
        {:error, :user_not_found}

      inviter ->
        {:ok, inviter}
    end
  end

  defp get_invitee(invitee_id), do: get_inviter(invitee_id)

  defp gen_token, do: :crypto.strong_rand_bytes(16) |> Base.url_encode64(padding: false)

  defp send_create_invite_event(invite = %Messaging.Persistence.Schemas.Invite{}) do
    Messaging.Broker.EventBus.publish(
      :messaging_events,
      %Messaging.Broker.Events.Invite.CreateEvent{
        id: invite.public_id,
        group_id: invite.group.public_id,
        inviter_id: invite.inviter.public_id,
        invitee_id: invite.invitee.public_id,
        token: invite.token,
        role: invite.role,
        status: invite.status
      }
    )
  end
end
