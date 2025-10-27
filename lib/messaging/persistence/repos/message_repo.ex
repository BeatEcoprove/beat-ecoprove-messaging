defmodule Messaging.Persistence.Repos.MessageRepo do
  alias BSON.ObjectId
  alias Messaging.Persistence.Schemas.Message

  @collection "messages"

  def create(message = %Message{}) do
    message
    |> Message.dump()
    |> then(fn doc ->
      case Mongo.insert_one(:mongo, @collection, doc) do
        {:ok, %{inserted_id: id}} ->
          case get(id) do
            {:error, error} ->
              error

            {:ok, message} ->
              message
          end

        {:error, reason} ->
          reason
      end
    end)
  end

  defp decode_message_id(id) do
    case ObjectId.decode(id) do
      {:ok, object_id} -> {:ok, object_id}
      :error -> {:error, :invalid_object_id}
    end
  end

  def get(id) when is_struct(id, ObjectId) do
    case Mongo.find_one(:mongo, @collection, %{"_id" => id}) do
      nil ->
        {:error, :message_not_found}

      doc ->
        {:ok, Message.load(doc)}
    end
  end

  def get(id) do
    with {:ok, object_id} <- decode_message_id(id),
         {:ok, doc} <- get(object_id) do
      {:ok, doc}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_all(group_id, opts \\ []) do
    Messaging.Mongo.paginate_cursor(
      @collection,
      %{
        "data.group_id": group_id
      },
      opts
    )
  end
end
