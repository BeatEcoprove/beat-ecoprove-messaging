defmodule MessagingApp.Members.Inputs.KickMemberInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @enforce_keys [:group_id, :actor_id, :member_id]
  defstruct [:group_id, :actor_id, :member_id]

  @type t :: %__MODULE__{
          group_id: String.t(),
          member_id: String.t()
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_id, :actor_id, :member_id])
    |> validate_required([:group_id, :actor_id, :member_id])
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:actor_id)
    |> Helpers.validate_uuid(:member_id)
  end
end
