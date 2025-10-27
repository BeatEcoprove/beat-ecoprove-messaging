defmodule MessagingWeb.UserSocket do
  use Phoenix.Socket

  alias MessagingApp.Schemas.Identity

  channel "group:*", MessagingWeb.GroupChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Messaging.Auth.Jwt.verify_token(token, :access) do
      {:ok, claims} ->
        socket =
          socket
          |> assign(:user, %Identity{
            id: claims["sub"],
            email: claims["email"],
            role: claims["role"],
            scope: claims["scope"] || []
          })

        {:ok, socket}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user.id}"
end
