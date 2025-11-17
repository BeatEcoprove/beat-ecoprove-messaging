defmodule Messaging.Persistence.Repos.UserRepo do
  alias Messaging.Persistence.Schemas.User
  alias Messaging.Repo

  def create(attr) do
    %User{}
    |> User.changeset(attr)
    |> Repo.insert()
  end

  def get(id) do
    Repo.get(User, id)
  end

  def already_created?(profile_id) do
    case Repo.get_by(User, profile_id: profile_id) do
      nil -> false
      _group -> true
    end
  end

  def get_by_public_id(id) do
    Repo.get_by(User, profile_id: id)
  end
end
