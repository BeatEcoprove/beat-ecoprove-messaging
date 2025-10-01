defmodule Messaging.Persistence.Schemas.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @type t :: %__MODULE__{
          public_id: String.t(),
          email: String.t(),
          role: String.t()
        }

  @primary_key {:id, :string, autogenerate: {Helpers, :generate_ulid, []}}
  schema "users" do
    field(:public_id, :string)
    field(:email, :string)
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
    |> cast(attrs, [:public_id, :email, :role])
    |> validate_required([:public_id, :email])
    |> Helpers.validate_email(:email)
    |> Helpers.validate_uuid(:public_id)
    |> unique_constraint(:email)
  end
end
