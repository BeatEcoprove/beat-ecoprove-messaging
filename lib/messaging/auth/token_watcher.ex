defmodule Messaging.Auth.TokenWatcher do
  use GenServer
  alias Messaging.Presence

  @check_interval 10_000
  @warning_time 100

  def start_link(_) do
    GenServer.start_link(__MODULE__, %{}, name: __MODULE__)
  end

  @impl true
  def init(state) do
    schedule_check()
    {:ok, state}
  end

  @impl true
  def handle_info(:check_tokens, state) do
    check_expiring_tokens()
    schedule_check()
    {:noreply, state}
  end

  defp schedule_check do
    Process.send_after(self(), :check_tokens, @check_interval)
  end

  defp get_id(key) do
    String.split(key, ":")
    |> List.last()
  end

  defp get_token(metadata) do
    metadata.metas
    |> List.first()
    |> (& &1.accessToken).()
  end

  defp check_expiring_tokens do
    Presence.list_online_users()
    |> Enum.each(fn {key, metadata} ->
      id = get_id(key)
      token = get_token(metadata)

      case Messaging.Auth.verify_token(token) do
        {:ok, claims} ->
          current_timestamp = :os.system_time(:second)
          time_left = claims["exp"] - current_timestamp

          if time_left <= @warning_time and time_left > 0 do
            notify_user(id)
          end

        {:error, _} ->
          notify_user(id)
      end
    end)
  end

  defp notify_user(user_id) do
    MessagingWeb.Endpoint.broadcast("auth:#{user_id}", "renew_tokens", %{
      message: "Your session is about to expire. Please refresh your token."
    })
  end
end
