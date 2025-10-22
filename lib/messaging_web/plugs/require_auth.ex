defmodule MessagingWeb.Plugs.RequireAuth do
  import Plug.Conn

  alias MessagingWeb.Controllers.ErrorController
  alias Messaging.Auth.Jwt

  def init(default), do: default

  def call(conn, _opts) do
    with ["Bearer " <> token] <- get_req_header(conn, "authorization"),
         {:ok, claims} <- Jwt.verify_token(token, :access) do
      assign(conn, :current_user, %MessagingApp.Schemas.Identity{
        id: claims["sub"],
        email: claims["email"],
        role: claims["role"],
        scope: claims["scope"]
      })
    else
      _ ->
        conn
        |> ErrorController.call_unauthorized()
        |> halt()
    end
  end
end
