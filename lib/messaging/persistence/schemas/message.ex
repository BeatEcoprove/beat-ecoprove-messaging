defmodule Messaging.Persistence.Schemas.Message do
  use Mongo.Collection

  @collection "messages"

  collection @collection do
    attribute(:type, String.t())
    attribute(:content, String.t())
    attribute(:mentions, list(String.t()), default: [])
    attribute(:reply_to, String.t() | nil, default: nil)
    attribute(:data, map(), default: %{})

    embeds_one :metadata, Metadata do
      attribute(:sender_id, String.t())
    end

    timestamps()
  end

  def create_text(content, sender_id, opts \\ []) do
    new()
    |> Map.put(:type, "text")
    |> Map.put(:content, content)
    |> Map.put(:mentions, Keyword.get(opts, :mentions, []))
    |> Map.put(:reply_to, Keyword.get(opts, :reply_to))
    |> Map.put(:metadata, %{sender_id: sender_id})
  end

  def create_borrow(content, sender_id, garment_id, opts \\ []) do
    new()
    |> Map.put(:type, "borrow")
    |> Map.put(:content, content)
    |> Map.put(:data, %{garment_id: garment_id})
    |> Map.put(:mentions, Keyword.get(opts, :mentions, []))
    |> Map.put(:reply_to, Keyword.get(opts, :reply_to))
    |> Map.put(:metadata, %{sender_id: sender_id})
  end
end
