defmodule MessagingApp.Messages.Inputs.CreateMessageInput do
  import Ecto.Changeset

  alias Messaging.Persistence.Helpers

  @enforce_keys [:group_id, :sender_id, :content]
  defstruct [
    :group_id,
    :sender_id,
    :content,
    :garment_id,
    reply_to: nil,
    mentions: [],
    m_type: "text"
  ]

  @type t :: %__MODULE__{
          group_id: String.t(),
          sender_id: String.t(),
          garment_id: String.t(),
          content: String.t(),
          reply_to: String.t() | nil,
          mentions: [String.t()],
          m_type: String.t()
        }

  def changeset(group, attrs) do
    group
    |> cast(attrs, [:group_id, :sender_id, :content, :garment_id])
    |> validate_required([:group_id, :sender_id, :content])
    |> Helpers.validate_uuid(:group_id)
    |> Helpers.validate_uuid(:sender_id)
  end
end
