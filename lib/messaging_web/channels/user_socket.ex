defmodule MessagingWeb.UserSocket do
  use Phoenix.Socket

  channel "auth:*", MessagingWeb.AuthChannel

  @impl true
  def connect(%{"userToken" => token}, socket, _connect_info) do
    case Messaging.Auth.verify_token(token) do
      {:ok, claims} ->
        socket =
          assign(socket, :user_data, %{
            id: claims["sub"],
            accessToken: token
          })

        {:ok, socket}

      {:error, _reason} ->
        {:error, "Not authorized"}
    end
  end

  @impl true
  def id(socket), do: "user:#{socket.assigns.user_data.id}"
end
