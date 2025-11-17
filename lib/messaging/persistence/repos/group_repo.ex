defmodule Messaging.Persistence.Repos.GroupRepo do
  import Ecto.Query

  alias Messaging.Persistence.Schemas.Member
  alias Messaging.Persistence.Schemas.Group
  alias Messaging.Repo

  @spec create(map()) :: {:ok, Group.t()} | {:error, Ecto.Changeset.t()}
  def create(attrs) do
    %Group{}
    |> Group.changeset(attrs)
    |> Repo.insert()
  end

  def delete(group), do: Repo.delete(group)

  def update(group, attr) do
    group
    |> Group.update_changeset(attr)
    |> Repo.update()
  end

  def already_created?(name, creator_id) do
    case Repo.get_by(Group, name: name, creator_id: creator_id) do
      nil -> false
      _group -> true
    end
  end

  def get(id) do
    Repo.get(Group, id)
  end

  def get_by_public_id(id) do
    Repo.get_by(Group, public_id: id)
  end

  def preload(ecto) do
    ecto
    |> Repo.preload([:members])
  end

  def get_public_groups do
    Group
    |> where([g], g.is_public == true)
    |> Repo.all()
  end

  def get_all_public(user_id, opts \\ []) do
    query =
      from(g in Group,
        left_join: m in Member,
        on: m.group_id == g.id,
        where: (g.creator_id != ^user_id or m.user_id != ^user_id) and g.is_public == true,
        select: g,
        distinct: g.id,
        preload: [members: m]
      )

    Repo.paginate_cursor(query, opts)
  end

  def get_belonging_groups(user_id, opts \\ []) do
    query =
      from(g in Group,
        left_join: m in Member,
        on: m.group_id == g.id,
        where: g.creator_id == ^user_id or m.user_id == ^user_id,
        select: g,
        distinct: g.id,
        preload: [members: m]
      )

    Repo.paginate_cursor(query, opts)
  end
end
