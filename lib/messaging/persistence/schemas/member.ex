defmodule Messaging.Persistence.Schemas.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  schema "members" do
    belongs_to(:group, Messaging.Persistence.Schemas.Group, type: :string)
    belongs_to(:user, Messaging.Persistence.Schemas.User, type: :string)

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:user_id, :group_id])
    |> validate_required([:user_id])
    |> foreign_key_constraint(:group_id)
    |> unique_constraint([:user_id, :group_id], name: :members_user_group_unique_index)
  end
end
