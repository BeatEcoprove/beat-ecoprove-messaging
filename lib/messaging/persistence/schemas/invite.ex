defmodule Messaging.Persistence.Schemas.Invite do
  use Ecto.Schema

  alias Messaging.Persistence.Helpers
  import Ecto.Changeset

  defmodule Role do
    @role %{
      0 => :member,
      1 => :admin
    }

    def get_role(role) do
      Map.get(@role, role, Map.get(@role, 0))
    end
  end

  defmodule Status do
    @status %{
      0 => :pending,
      1 => :accepted,
      2 => :declined,
      3 => :expired,
      4 => :revoked
    }

    def get_status(status), do: Map.get(@status, status, Map.get(@status, 0))

    def get_status_key(value) do
      @status
      |> Enum.find(fn {_k, v} -> v == value end)
      |> case do
        {key, _v} -> key
        nil -> 0
      end
    end
  end

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
    field(:status, :integer, default: 0)
    field(:role, :integer, default: 0)

    belongs_to(:group, Messaging.Persistence.Schemas.Group, type: :string)
    belongs_to(:inviter, Messaging.Persistence.Schemas.User, type: :string)

    # FIXME this will probably break, because if the service doesn't have the user, it will need to fetch it somehow
    belongs_to(:invitee, Messaging.Persistence.Schemas.User, type: :string)

    timestamps()
    field(:deleted_at, :utc_datetime_usec, default: nil)
  end

  def changeset_status(invite, status) when is_atom(status) do
    invite
    |> cast(%{"status" => Status.get_status_key(status)}, [:status])
    |> validate_required([:status],
      message: "Messaging.Validation.InviteStatus.Description"
    )
    |> validate_number(:status,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 5,
      message: "Messaging.Validation.InvalidInviteStatus.Description"
    )
  end

  def changeset(invite, attrs) do
    invite
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
      message: "Messaging.Validation.RequiredField.Description"
    )
    |> validate_number(:status,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 5,
      message: "Messaging.Validation.InvalidInviteStatus.Description"
    )
    |> validate_number(:role,
      greater_than_or_equal_to: 0,
      less_than_or_equal_to: 1,
      message: "Messaging.Validation.InvalidRole.Description"
    )
    |> Helpers.validate_uuid(:public_id)
    |> unique_constraint(:token,
      name: :token_index,
      message: "Messaging.Validation.DuplicateInviteToken.Description"
    )
  end
end
