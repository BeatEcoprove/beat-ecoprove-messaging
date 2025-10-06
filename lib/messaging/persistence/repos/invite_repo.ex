defmodule Messaging.Persistence.Repos.InviteRepo do
  import Ecto.Query

  alias Messaging.Persistence.Schemas.Invite
  alias Messaging.Repo

  def create(attr) do
    with {:ok, invite} <- %Invite{} |> Invite.changeset(attr) |> Repo.insert() do
      {:ok, Repo.preload(invite, [:group, :inviter, :invitee])}
    end
  end

  def change_status(invite, status) when is_atom(status) do
    invite
    |> Invite.changeset_status(status)
    |> Repo.update()
  end

  def get_by_public_id(id) do
    from(i in Invite,
      where: i.public_id == ^id,
      preload: [:group, :inviter, :invitee]
    )
    |> Repo.one()
  end

  def get_by_token(token) do
    case Repo.get_by(Invite, token: token) do
      nil ->
        {:error, nil}

      invite ->
        {:ok, invite}
    end
  end
end
