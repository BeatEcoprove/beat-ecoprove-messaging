defmodule MessagingWeb.Router do
  use MessagingWeb, :router

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()

    plug :accepts, ["multipart", "json"]
    plug MessagingWeb.Plugs.FormatResponse
  end

  pipeline :auth_required do
    plug MessagingWeb.Plugs.RequireAuth
  end

  scope "/api", MessagingWeb.Controllers do
    pipe_through [:api, :auth_required]

    resources "/groups", GroupController, only: [:index, :show, :create, :delete, :update]

    resources "/groups/:id/invites", InviteController, only: [:create]
    post "/invites/accept", InviteController, :accept
  end
end
