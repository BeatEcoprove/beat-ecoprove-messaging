defmodule MessagingApp.Group.Inputs.UpdateGroupInput do
  import Ecto.Changeset

  @enforce_keys [:name, :description]
  defstruct [:name, :description, is_public: false]

  @type t :: %__MODULE__{
          name: String.t(),
          description: String.t(),
          is_public: boolean() | false
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:name, :description, :is_public])
    |> validate_length(:name, min: 1, max: 100)
    |> validate_length(:description, max: 500)
    |> validate_inclusion(:is_public, [true, false])
  end
end
