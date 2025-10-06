defmodule MessagingApp.Members.Inputs.ChangeRoleInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Schemas.User
  alias Messaging.Persistence.Helpers

  @enforce_keys [:group_id, :current_user, :role]
  defstruct [:group_id, :current_user, :role]

  @type t :: %__MODULE__{
          group_id: String.t(),
          current_user: User.t(),
          role: String.t()
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_id, :role])
    |> validate_required([:group_id, :role])
    |> Helpers.validate_uuid(:group_id)
    |> validate_inclusion(:role, ["member", "moderator", "admin"])
  end
end
