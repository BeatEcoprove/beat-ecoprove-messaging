defmodule MessagingWeb.UserSocket do
  use Phoenix.Socket

  channel "group:*", MessagingWeb.GroupChannel

  @impl true
  def connect(%{"token" => token}, socket, _connect_info) do
    case Messaging.Auth.Jwt.verify_token(token, :access) do
      {:ok, claims} ->
        socket =
          socket
          |> assign(:user_id, claims["sub"])
          |> assign(:email, claims["email"])
          |> assign(:role, claims["role"])
          |> assign(:scope, claims["scope"] || [])

        {:ok, socket}

      {:error, _reason} ->
        :error
    end
  end

  def connect(_params, _socket, _connect_info), do: :error

  @impl true
  def id(socket), do: "user_socket:#{socket.assigns.user_id}"
end
