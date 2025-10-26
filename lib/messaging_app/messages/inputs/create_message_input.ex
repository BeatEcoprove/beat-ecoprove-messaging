defmodule MessagingApp.Messages.Inputs.CreateMessageInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @enforce_keys [:member_id, :group_id, :content, :type]
  defstruct [:member_id, :group_id, :content, type: :text]

  @type t :: %__MODULE__{
          member_id: String.t(),
          group_id: String.t(),
          content: String.t()
        }

  def changeset(input, attrs) do
    input
    |> cast(attrs, [:member_id, :group_id, :content])
    |> validate_required([:member_id, :group_id, :content])
    |> Helpers.validate_uuid(:member_id)
    |> Helpers.validate_uuid(:group_id)
  end
end
