defmodule Messaging.Persistence.Schemas.Message do
  import Ecto.Changeset

  defstruct [
    :id,
    :title,
    :content,
    :group_id,
    :sender_id,
    :created_at,
    :updated_at
  ]

  @type t :: %__MODULE__{
          id: String.t() | nil,
          title: String.t(),
          content: String.t(),
          group_id: String.t(),
          sender_id: String.t(),
          created_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  def new(title, content, group_id, sender_id) do
    now = DateTime.utc_now()

    %__MODULE__{
      id: generate_id(),
      title: title,
      content: content,
      group_id: group_id,
      sender_id: sender_id,
      created_at: now,
      updated_at: now
    }
  end

  def changeset(message \\ %__MODULE__{}, attrs) do
    data =
      case message do
        %__MODULE__{} = msg -> Map.from_struct(msg)
        %{} = map -> map
      end

    types = %{
      id: :string,
      title: :string,
      content: :string,
      group_id: :string,
      sender_id: :string,
      created_at: :utc_datetime,
      updated_at: :utc_datetime
    }

    {data, types}
    |> cast(attrs, [:title, :content, :group_id, :sender_id])
    |> validate_required([:title, :content, :group_id, :sender_id])
    |> validate_length(:title, min: 1, max: 200)
    |> validate_length(:content, min: 1, max: 5000)
    |> validate_uuid(:group_id)
    |> validate_uuid(:sender_id)
  end

  def create(attrs) do
    changeset = changeset(%__MODULE__{}, attrs)

    if changeset.valid? do
      message =
        attrs
        |> Map.put(:id, generate_id())
        |> Map.put(:created_at, DateTime.utc_now())
        |> Map.put(:updated_at, DateTime.utc_now())
        |> then(&struct(__MODULE__, &1))

      {:ok, message}
    else
      {:error, changeset}
    end
  end

  def update(%__MODULE__{} = message, attrs) do
    changeset =
      message
      |> changeset(attrs)
      |> put_change(:updated_at, DateTime.utc_now())

    if changeset.valid? do
      updated_message = apply_changes(changeset) |> to_struct()
      {:ok, updated_message}
    else
      {:error, changeset}
    end
  end

  def to_document(%__MODULE__{} = message) do
    message
    |> Map.from_struct()
    |> Map.delete(:__struct__)
  end

  def from_document(%{} = doc) do
    struct(__MODULE__, %{
      id: doc["_id"] || doc[:id],
      title: doc["title"] || doc[:title],
      content: doc["content"] || doc[:content],
      group_id: doc["group_id"] || doc[:group_id],
      sender_id: doc["sender_id"] || doc[:sender_id],
      created_at: parse_datetime(doc["created_at"] || doc[:created_at]),
      updated_at: parse_datetime(doc["updated_at"] || doc[:updated_at])
    })
  end

  defp validate_uuid(changeset, field) do
    validate_change(changeset, field, fn ^field, value ->
      case Ecto.UUID.cast(value) do
        {:ok, _} -> []
        :error -> [{field, "must be a valid UUID"}]
      end
    end)
  end

  defp generate_id do
    Ecto.UUID.generate()
  end

  defp to_struct(changeset) do
    changeset.changes
    |> Map.merge(changeset.data)
    |> then(&struct(__MODULE__, &1))
  end

  defp parse_datetime(nil), do: nil
  defp parse_datetime(%DateTime{} = dt), do: dt

  defp parse_datetime(string) when is_binary(string) do
    case DateTime.from_iso8601(string) do
      {:ok, dt, _} -> dt
      _ -> nil
    end
  end
end
