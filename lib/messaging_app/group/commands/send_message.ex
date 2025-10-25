defmodule MessagingApp.Group.Commands.SendMessage do
  alias MessagingApp.Group.Events.SendMessageEvent

  def call(input = %SendMessageEvent{}) do
    IO.puts("Payload hey: #{inspect(input)}")
    # validate input
    # find member that is trying to send message
    # store it on mongo db
    # reply
    {:ok, "heu"}
  end
end
