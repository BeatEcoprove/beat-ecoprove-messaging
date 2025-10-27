defmodule Messaging.Persistence.Schemas.Notification do
  use Mongo.Collection
  @collection "notifications"

  collection @collection do
    attribute(:type, String.t())
    attribute(:title, String.t())
    attribute(:body, String.t())
    attribute(:read, boolean(), default: false)
    attribute(:data, map(), default: %{})

    embeds_one :metadata, Metadata do
      attribute(:recipient_id, String.t())
      attribute(:actor_id, String.t())
      attribute(:reference_id, String.t() | nil)
      attribute(:reference_type, String.t() | nil)
    end

    timestamps()
  end

  # create notification for mentions
  # create notification for replies
  # create notification for borrow requests (request and aprove)

  def create_invite(%{
        recipient_id: recipient_id,
        actor_id: actor_id,
        group_id: group_id,
        group_name: group_name
      }) do
    new()
    |> Map.put(:type, "group_invite")
    |> Map.put(:title, "Group invitation")
    |> Map.put(:body, "You've been invited to join #{group_name}")
    |> Map.put(:data, %{group_id: group_id})
    |> Map.put(:metadata, %{
      recipient_id: recipient_id,
      actor_id: actor_id,
      reference_id: group_id,
      reference_type: "group"
    })
  end

  def mark_read(notification) do
    Map.put(notification, :read, true)
  end
end
