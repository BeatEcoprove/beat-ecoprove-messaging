defmodule Messaging.Persistence.Schemas.Member do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  @primary_key false
  schema "members" do
    field(:id, :string)
    belongs_to(:group, Messaging.Persistence.Schemas.Group, type: :string, primary_key: true)
    belongs_to(:user, Messaging.Persistence.Schemas.User, type: :string, primary_key: true)

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def changeset(member, attrs) do
    member
    |> cast(attrs, [:id, :user_id, :group_id])
    |> validate_required([:id, :user_id, :group_id])
    |> foreign_key_constraint(:group_id)
    |> unique_constraint([:user_id, :group_id], name: :members_user_group_unique_index)
  end
end
