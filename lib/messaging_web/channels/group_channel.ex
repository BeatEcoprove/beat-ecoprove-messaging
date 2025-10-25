defmodule MessagingWeb.GroupChannel do
  use MessagingWeb, :channel

  alias Messaging.Auth.UserPresence
  alias Messaging.Persistence.Repos.MemberRepo
  alias Messaging.Persistence.Repos.GroupRepo
  alias MessagingApp.Group

  defp get_member(user_id, group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        case MemberRepo.get_by_public_id(user_id, group.id) |> MemberRepo.preload() do
          nil ->
            {:error, :member_not_found}

          member ->
            {:ok, member.user_id, group.id}
        end
    end
  end

  @impl true
  def join("group:" <> group_id, _payload, socket) do
    user_id = socket.assigns.user_id

    case get_member(user_id, group_id) do
      {:error, _reason} ->
        {:error, %{reason: "unauthorized"}}

      {:ok, priv_member_id, priv_group_id} ->
        socket =
          socket
          |> assign(:group_id, priv_group_id)
          |> assign(:member_id, priv_member_id)

        send(self(), :after_join)
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
  def handle_in("send_message", payload, socket) do
    IO.puts("Payload: #{inspect(payload)}")

    new_stuff = %MessagingApp.Group.Events.SendMessageEvent{
      payload: %{
        content: "adad",
        mentions: [],
        reply_to: nil
      },
      metadata: %{
        sender_id: "dadadad"
      }
    }

    case Group.send_message(payload) do
      {:error, _reason} ->
        {:reply, {:error, %{errors: format_errors(payload)}}, socket}

      {:ok, _reason} ->
        {:reply, {:ok, %{payload: payload}}, socket}
    end
  end

  defp format_errors(payload) do
    payload
  end
end
