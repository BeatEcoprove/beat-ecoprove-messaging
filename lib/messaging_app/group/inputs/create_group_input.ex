defmodule MessagingApp.Group.Inputs.CreateGroupInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Schemas.User
  alias Messaging.Persistence.Helpers

  @enforce_keys [:name, :description, :creator]
  defstruct [:name, :description, :creator, is_public: false]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          is_public: boolean() | false,
          creator: User.t()
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description, :is_public, :creator])
    |> validate_required([:name, :description, :creator])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> Helpers.validate_uuid(:creator)
    |> validate_inclusion(:is_public, [true, false])
  end
end
