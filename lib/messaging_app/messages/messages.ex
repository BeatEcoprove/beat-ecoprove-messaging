defmodule MessagingApp.Messages do
  alias Messaging.Persistence.Repos.MessageRepo

  def create_message() do
  end

  def get_all_messages(group_id, opts \\ []), do: MessageRepo.get_all(group_id, opts)

  def get(message_id), do: MessageRepo.get(message_id)
end
