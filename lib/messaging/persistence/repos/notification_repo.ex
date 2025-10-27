defmodule Messaging.Persistence.Repos.NotificationRepo do
  alias BSON.ObjectId
  alias Messaging.Persistence.Schemas.Notification

  @collection "notifications"

  def create(notification = %Notification{}) do
    notification
    |> Notification.dump()
    |> then(fn doc ->
      case Mongo.insert_one(:mongo, @collection, doc) do
        {:ok, %{inserted_id: id}} ->
          case get(id) do
            {:error, error} ->
              {:error, error}

            {:ok, notification} ->
              {:ok, notification}
          end

        {:error, reason} ->
          {:error, reason}
      end
    end)
  end

  defp decode_notification_id(id) do
    case ObjectId.decode(id) do
      {:ok, object_id} -> {:ok, object_id}
      :error -> {:error, :invalid_object_id}
    end
  end

  def get(id) when is_struct(id, ObjectId) do
    case Mongo.find_one(:mongo, @collection, %{"_id" => id}) do
      nil ->
        {:error, :notification_not_found}

      doc ->
        {:ok, Notification.load(doc)}
    end
  end

  def get(id) do
    with {:ok, object_id} <- decode_notification_id(id),
         {:ok, doc} <- get(object_id) do
      {:ok, doc}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_all(actor_id, opts \\ []) do
    Messaging.Mongo.paginate_cursor(
      @collection,
      %{
        "metadata.actor_id": actor_id
      },
      opts
    )
  end
end
