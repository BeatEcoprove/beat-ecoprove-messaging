defmodule MessagingApp.Invite.Commands.DeclineInvite do
  alias Messaging.Persistence.Schemas.Invite.Status
  alias Messaging.Persistence.Repos.InviteRepo
  alias Messaging.Redis.RClient
  alias Messaging.Redis.Keys.InviteKey

  @spec call(any(), binary()) :: {:error, any()} | {:ok, any()}
  def call(invitee_id, token) do
    with {:ok, invite} <- get_invite(token),
         {:ok, true} <- check_validity?(invite, invitee_id),
         {:ok, updated_invite} <-
           decline_invite(invite) do
      {:ok, updated_invite}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp check_validity?(invite, invitee_id) do
    with true <- invite.invitee.public_id == invitee_id || {:error, :invite_expired},
         true <-
           invite.status == Status.get_status_key(:pending) || {:error, :invite_fail_accept} do
      {:ok, true}
    else
      {:error, reason} -> {:error, reason}
    end
  end

  defp decline_invite(invite) do
    case InviteRepo.change_status(invite, :declined) do
      {:ok, updated_invite} ->
        {:ok, updated_invite}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp get_invite(token) do
    case RClient.get(InviteKey.key(token)) do
      nil ->
        with {:ok, invite} <- InviteRepo.get_by_token(token),
             _status <- InviteRepo.change_status(invite, :expired) do
          {:error, :invite_expired}
        else
          {:error, _reason} ->
            {:error, :invite_not_found}
        end

      pub_id ->
        case InviteRepo.get_by_public_id(pub_id) do
          nil ->
            {:error, :invite_not_found}

          invite ->
            {:ok, invite}
        end
    end
  end
end
