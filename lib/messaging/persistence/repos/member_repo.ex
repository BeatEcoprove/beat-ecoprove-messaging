defmodule Messaging.Persistence.Repos.MemberRepo do
  import Ecto.Query

  alias Messaging.Persistence.Schemas.User
  alias Messaging.Repo
  alias Messaging.Persistence.Schemas.Member

  @spec create(map()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def create(repo \\ Repo, attr) do
    %Member{}
    |> Member.changeset(attr)
    |> repo.insert()
  end

  def is_member(member_id, group_id) do
    result =
      case get_by_public_id(member_id, group_id) do
        nil -> false
        _member -> true
      end

    IO.puts("result = #{inspect(result)}")
    result
  end

  def get_by_public_id(member_id, group_id) do
    from(m in Member,
      left_join: u in User,
      on: u.public_id == ^member_id,
      where: m.group_id == ^group_id and is_nil(m.deleted_at),
      limit: 1,
      select: m
    )
    |> Repo.one()
  end

  def preload(ecto) do
    ecto
    |> Repo.preload([:user])
  end

  def delete(member) do
    member
    |> Ecto.Changeset.change(deleted_at: DateTime.utc_now())
    |> Repo.update()
  end
end
