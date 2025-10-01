defmodule Messaging.Persistence.Schemas.Invite do
  use Ecto.Schema

  alias Messaging.Persistence.Helpers
  import Ecto.Changeset

  @type t :: %__MODULE__{}

  # @status_pending 0
  # @status_accepted 1
  # @status_declined 2
  # @status_expired 4
  # @status_revoked 5

  # @role_member 0
  # @role_admin 1

  @primary_key {:id, :string, autogenerate: {Helpers, :generate_ulid, []}}
  @derive {Phoenix.Param, key: :id}
  schema "invites" do
    field(:public_id, :string, autogenerate: {Ecto.UUID, :generate, []})
    field(:token, :string)
    # 0 (pending) / 1 (accepted) / 2 (declined) / 4 (expired) / 5 (revoked)
    field(:status, :integer)
    # 0 (member) / 1 (admin)
    field(:role, :integer)

    belongs_to(:group, Messaging.Persistence.Schemas.Group, type: :string)
    belongs_to(:inviter, Messaging.Persistence.Schemas.User, type: :string)

    # FIXME this will probably break, because if the service doesn't have the user, it will need to fetch it somehow
    belongs_to(:invitee, Messaging.Persistence.Schemas.User, type: :string)

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def changeset(group, attrs) do
    group
    |> cast(attrs, [
      :public_id,
      :group_id,
      :inviter_id,
      :invitee_id,
      :token,
      :status,
      :role,
      :deleted_at
    ])
    |> validate_required([:group_id, :inviter_id, :invitee_id],
      message: "name, description, and is_public are required fields"
    )
    |> validate_number(:status,
      min: 0,
      max: 5,
      allow_nil: true,
      message: "Status must be a integer of the range of [0..5]"
    )
    |> validate_number(:role,
      min: 0,
      max: 1,
      allow_nil: true,
      message: "Role must be the range of [0..1], (member/admin)"
    )
    |> validate_number(:sustainability_points,
      min: 0,
      allow_nil: true,
      message: "Sustainability points must be a non-negative number"
    )
    |> Helpers.validate_uuid(:public_id)
    |> Helpers.validate_uuid(:token)
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:inviter_id)
    |> Helpers.validate_uuid(:invitee_id)
    |> unique_constraint(:token,
      name: :token_index,
      message: "Cannot exist two invites with the same token"
    )
  end
end
