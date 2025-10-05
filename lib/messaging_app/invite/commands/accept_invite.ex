defmodule MessagingApp.Invite.Commands.AcceptInvite do
  alias Messaging.Persistence.Schemas.Invite.Status
  alias Messaging.Repo
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Persistence.Repos.GroupRepo
  alias Messaging.Persistence.Repos.UserRepo
  alias Messaging.Persistence.Repos.InviteRepo
  alias Messaging.Redis.RClient
  alias Messaging.Redis.Keys.InviteKey

  @spec call(any(), binary()) :: {:error, any()} | {:ok, any()}
  def call(invitee_id, token) do
    with {:ok, invite} <- get_invite(token),
         {:ok, true} <- check_validity?(invite, invitee_id),
         {:ok, group} <-
           accept_invite(invite) do
      {:ok, group}
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

  defp accept_invite(invite) do
    Repo.transact(fn ->
      with {:ok, group} <- get_group(invite.group_id),
           {:ok, user} <- get_invitee(invite.invitee_id),
           {:ok, _} <-
             MemberRepo.create(%{
               user_id: user.id,
               group_id: group.id
             }),
           {:ok, _} <-
             InviteRepo.change_status(invite, :accepted) || {:error, :invite_fail_accept} do
        {:ok, group}
      else
        {:error, reason} ->
          {:error, reason}
      end
    end)
    |> case do
      {:error, reason} ->
        InviteRepo.change_status(invite, :revoked)
        {:error, reason}

      {:ok, group} ->
        {:ok, group}
    end
  end

  defp get_group(group_id) do
    case(GroupRepo.get(group_id)) do
      nil -> {:error, :group_not_found}
      group -> {:ok, group}
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

  defp get_invitee(invitee_id) do
    case UserRepo.get(invitee_id) do
      nil ->
        {:error, :user_not_found}

      inviter ->
        {:ok, inviter}
    end
  end
end
