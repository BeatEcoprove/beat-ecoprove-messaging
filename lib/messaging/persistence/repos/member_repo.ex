defmodule Messaging.Persistence.Repos.MemberRepo do
  alias Messaging.Repo
  alias Messaging.Persistence.Schemas.Member

  @spec create(map()) :: {:ok, Member.t()} | {:error, Ecto.Changeset.t()}
  def create(repo \\ Repo, attr) do
    %Member{}
    |> Member.changeset(attr)
    |> repo.insert()
  end
end
