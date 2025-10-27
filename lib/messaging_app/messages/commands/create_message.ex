defmodule MessagingApp.Messages.Commands.CreateMessage do
  alias MessagingApp.Messages.Inputs.CreateMessageInput

  def call(input = %CreateMessageInput{}) do
    Messaging.Broker.EventBus.publish(
      :chat_events,
      %Messaging.Broker.Events.Messages.SendMessageEvent{
        group_id: input.group_id,
        sender_id: input.sender_id,
        content: input.content,
        reply_to: input.reply_to,
        mentions: input.mentions,
        garment_id: input.garment_id,
        type: input.m_type
      }
    )
  end
end
