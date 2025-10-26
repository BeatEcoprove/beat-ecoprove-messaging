defmodule MessagingApp.Messages do
  alias MessagingApp.Messages.Queries.GetAllMessages
  alias MessagingApp.Messages.Commands.CreateMessage

  def get_all_messages(user_id, group_id, opts \\ []),
    do: GetAllMessages.call(user_id, group_id, opts)

  def create_message(attr), do: CreateMessage.call(attr)
end
