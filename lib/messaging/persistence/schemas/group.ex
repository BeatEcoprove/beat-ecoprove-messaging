defmodule Messaging.Persistence.Schemas.Group do
  use Ecto.Schema

  @avatar_url "https://robohash.org/"

  alias Messaging.Persistence.Helpers
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key {:id, :string, autogenerate: {Helpers, :generate_ulid, []}}
  @derive {Phoenix.Param, key: :id}
  schema "groups" do
    field(:public_id, :string, autogenerate: {Ecto.UUID, :generate, []})
    field(:name, :string)
    field(:description, :string)
    field(:is_public, :boolean, default: false)

    field(:sustainability_points, :float, default: 0.0)
    field(:xp, :float, default: 0.0)
    field(:creator_id, :string)
    field(:avatar_img, :string, default: @avatar_url <> Helpers.generate_ulid())

    has_many(:members, Messaging.Persistence.Schemas.Member)

    many_to_many(:users, Messaging.Persistence.Schemas.User,
      join_through: Messaging.Persistence.Schemas.Member
    )

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def get_members_count(group) do
    if Ecto.assoc_loaded?(group.members) do
      {:ok, length(group.members)}
    else
      {:error, :not_preloaded}
    end
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :name,
      :description,
      :is_public,
      :sustainability_points,
      :xp,
      :creator_id,
      :avatar_img,
      :deleted_at
    ])
    |> validate_required([:name, :description, :is_public],
      message: "name, description, and is_public are required fields"
    )
    |> validate_length(:name,
      min: 1,
      max: 100,
      message: "Group name must be between 1 and 100 characters"
    )
    |> validate_length(:description,
      min: 1,
      max: 500,
      message: "Description must be between 1 and 500 characters"
    )
    |> validate_number(:sustainability_points,
      min: 0,
      allow_nil: true,
      message: "Sustainability points must be a non-negative number"
    )
    |> validate_number(:xp, min: 0, allow_nil: true, message: "XP must be a non-negative number")
    |> Helpers.validate_uuid(:creator_id)
    |> unique_constraint(:name, name: :groups_name_index, message: "Group name already exists")
  end

  def update_changeset(group, attrs) do
    filtered_attrs =
      attrs
      |> Enum.reject(fn {_k, v} -> is_nil(v) end)
      |> Enum.into(%{})

    group
    |> cast(filtered_attrs, [
      :name,
      :description,
      :is_public
    ])
    |> validate_length(:name,
      min: 1,
      max: 100,
      message: "Group name must be between 1 and 100 characters"
    )
    |> validate_length(:description,
      min: 1,
      max: 500,
      message: "Description must be between 1 and 500 characters"
    )
    |> validate_number(:sustainability_points,
      min: 0,
      allow_nil: true,
      message: "Sustainability points must be a non-negative number"
    )
    |> unique_constraint(:name, name: :groups_name_index, message: "Group name already exists")
  end
end
