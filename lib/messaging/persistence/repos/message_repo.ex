defmodule Messaging.Persistence.Repos.MessageRepo do
  alias Messaging.Persistence.Schemas.Message

  @collection "messages"

  def create(message = %Message{}) do
    message
    |> Message.dump()
    |> then(fn doc ->
      case Mongo.insert_one(:mongo, @collection, doc) do
        {:ok, %{inserted_id: id}} -> {:ok, get(id)}
        {:error, reason} -> reason
      end
    end)
  end

  def get(id) do
    case Mongo.find_one(:mongo, @collection, %{"_id" => id}) do
      nil -> nil
      doc -> Message.load(doc)
    end
  end
end
