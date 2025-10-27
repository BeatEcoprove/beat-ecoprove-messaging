defmodule MessagingWeb.GroupChannel do
  use MessagingWeb, :channel

  alias Messaging.Auth.{Group, UserPresence}
  alias MessagingApp.Messages
  alias MessagingApp.Messages.Inputs.CreateMessageInput

  @impl true
  def join("group:" <> group_id, _payload, socket) do
    user = socket.assigns.user

    case Group.verify_membership(user.id, group_id) do
      {:error, _error} ->
        {:error, :group_not_authorized}

      {:ok, result} ->
        socket =
          socket
          |> assign(:group, result.group)
          |> assign(:member, result.member)

        {:ok, socket}
    end
  end

  @impl true
  def handle_info(:after_join, socket) do
    user_id = socket.assigns.user_id

    {:ok, _} =
      UserPresence.track(socket, user_id, %{
        online_at: System.system_time(:second),
        email: socket.assigns.email
      })

    push(socket, "presence_state", UserPresence.list(socket))

    broadcast_from!(socket, "member_joined", %{
      user_id: user_id,
      joined_at: DateTime.utc_now()
    })

    {:noreply, socket}
  end

  @impl true
  def handle_info({:broadcast_message, event, payload}, socket) do
    push(socket, event, payload)
    {:noreply, socket}
  end

  @impl true
  def handle_in("send_text_msg", payload, socket) do
    group = socket.assigns.group
    user = socket.assigns.user

    input = %CreateMessageInput{
      group_id: group.public_id,
      sender_id: user.id,
      content: payload["content"],
      reply_to: payload["reply_to"],
      mentions: payload["mentions"],
      m_type: "text"
    }

    handle(input, socket)
  end

  @impl true
  def handle_in("send_borrow_msg", payload, socket) do
    group = socket.assigns.group
    user = socket.assigns.user

    input = %CreateMessageInput{
      group_id: group.public_id,
      sender_id: user.id,
      content: payload["content"],
      reply_to: payload["reply_to"],
      mentions: payload["mentions"],
      garment_id: payload["garment_id"],
      m_type: "borrow"
    }

    handle(input, socket)
  end

  defp handle(input, socket) do
    case Messages.create_message(input) do
      :ok ->
        {:reply, {:ok, %{status: "pending"}}, socket}

      {:error, reason} ->
        {:reply, {:error, %{reason: reason}}, socket}
    end
  end
end
