defmodule MessagingApp.Messages.Commands.CreateMessage do
  alias MessagingApp.Messages.Inputs.CreateMessageInput

  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Persistence.Repos.GroupRepo
  alias Messaging.Persistence.Repos.MessageRepo
  alias Messaging.Persistence.Schemas.Message

  def call(input = %CreateMessageInput{}) do
    with {:ok, group} <- get_group(input.group_id),
         {:ok, member} <- get_member(input.member_id, group.id) do
      create_message =
        case input.type do
          :text ->
            Message.create_text(%{
              content: input.content,
              sender_id: member.public_id,
              group_id: input.group_id
            })

          :borrow ->
            Message.create_borrow(%{
              content: input.content,
              sender_id: member.public_id,
              garment_id: member.public_id,
              group_id: input.group_id
            })
        end

      case MessageRepo.create(create_message) do
        {:ok, message} ->
          {:ok, message}

        {:error, _reason} ->
          {:error, :message_created_fail}
      end
    end
  end

  defp get_member(member_id, group_id) do
    case MemberRepo.get_by_public_id(member_id, group_id) do
      nil ->
        {:error, :member_not_found}

      member ->
        {:ok, member}
    end
  end

  def get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
