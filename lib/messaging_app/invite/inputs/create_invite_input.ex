defmodule MessagingApp.Invite.Inputs.CreateInviteInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @enforce_keys [:group_id, :inviter_id, :invitee_id, :role]
  defstruct [:group_id, :inviter_id, :invitee_id, role: 0]

  @type t :: %__MODULE__{
          group_id: String.t(),
          inviter_id: String.t(),
          invitee_id: String.t(),
          role: integer
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_id, :inviter_id, :invitee_id, :role])
    |> validate_required([:group_id, :inviter_id, :invitee_id, :role])
    |> validate_number(:role, min: 0, max: 5)
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:inviter_id)
    |> Helpers.validate_uuid(:invitee_id)
  end
end
