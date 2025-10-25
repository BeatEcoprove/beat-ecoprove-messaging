defmodule MessagingApp.Group.Events.SendMessageEvent do
  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          payload: payload(),
          metadata: metadata()
        }

  @type payload :: %{
          content: String.t(),
          mentions: list(String.t()),
          reply_to: String.t() | nil
        }

  @type metadata :: %{
          sender_id: String.t()
        }

  @primary_key false
  embedded_schema do
    embeds_one :payload, Payload, primary_key: false do
      field(:content, :string)
      field(:mentions, {:array, :string})
      field(:reply_to, :string)
    end

    embeds_one :metadata, Metadata, primary_key: false do
      field(:sender_id, :string)
    end
  end

  @spec changeset(map()) :: Ecto.Changeset.t()
  def changeset(attrs) do
    %__MODULE__{}
    |> cast(attrs, [])
    |> cast_embed(:payload, required: true, with: &payload_changeset/2)
    |> cast_embed(:metadata, required: true, with: &metadata_changeset/2)
  end

  defp payload_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:content, :mentions, :reply_to])
    |> validate_required([:content])
    |> validate_length(:content, min: 1, max: 5000)
  end

  defp metadata_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:sender_id])
    |> validate_required([:sender_id])
  end

  @spec validate(map()) :: {:ok, t()} | {:error, Ecto.Changeset.t()}
  def validate(params) do
    case changeset(params) do
      %{valid?: true} = changeset -> {:ok, apply_changes(changeset)}
      changeset -> {:error, changeset}
    end
  end
end
