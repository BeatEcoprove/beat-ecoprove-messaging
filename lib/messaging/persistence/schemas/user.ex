defmodule Messaging.Persistence.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @type t :: %__MODULE__{
          auth_id: String.t(),
          profile_id: String.t(),
          display_name: String.t(),
          role: String.t()
        }

  @primary_key {:id, :string, autogenerate: {Helpers, :generate_ulid, []}}
  schema "users" do
    field(:auth_id, :string)
    field(:profile_id, :string)
    field(:display_name, :string)
    field(:role, :string, default: "client")

    has_many(:members, Messaging.Persistence.Schemas.Member)

    many_to_many(:groups, Messaging.Persistence.Schemas.Group,
      join_through: Messaging.Persistence.Schemas.Member
    )

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:auth_id, :profile_id, :display_name, :role])
    |> validate_required([:auth_id, :profile_id, :display_name, :role])
    |> Helpers.validate_uuid(:auth_id)
    |> Helpers.validate_uuid(:profile_id)
    |> unique_constraint(:profile_id)
  end
end
