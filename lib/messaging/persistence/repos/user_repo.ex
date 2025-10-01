defmodule Messaging.Persistence.Repos.UserRepo do
  alias Messaging.Persistence.Schemas.User
  alias Messaging.Repo

  def create(attr) do
    %User{}
    |> User.changeset(attr)
    |> Repo.insert()
  end
end
