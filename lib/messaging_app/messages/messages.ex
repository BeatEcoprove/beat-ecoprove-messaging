defmodule MessagingApp.Messages do
  alias Messaging.Persistence.Repos.MessageRepo

  alias MessagingApp.Messages.Commands.CreateMessage

  def get_all_messages(group_id, opts \\ []), do: MessageRepo.get_all(group_id, opts)

  def get(message_id), do: MessageRepo.get(message_id)

  def create_message(attr), do: CreateMessage.call(attr)
end
