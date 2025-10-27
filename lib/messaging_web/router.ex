defmodule MessagingWeb.Router do
  use MessagingWeb, :router

  pipeline :api do
    plug Plug.Parsers,
      parsers: [:urlencoded, :multipart, :json],
      pass: ["*/*"],
      json_decoder: Phoenix.json_library()

    plug :accepts, ["multipart", "json"]
  end

  pipeline :auth_required do
    plug MessagingWeb.Plugs.RequireAuth
  end

  scope "/api", MessagingWeb.Controllers do
    pipe_through [:api, :auth_required]

    resources "/notifications", NotificationController, only: [:index, :show]

    resources "/groups", GroupController, only: [:index, :show, :create, :delete, :update] do
      delete "/kick", MemberController, :kick
      patch "/role", MemberController, :change_role

      resources "/messages", MessageController, only: [:index, :show]
    end

    resources "/groups/:id/invites", InviteController, only: [:create]
    post "/invites/accept", InviteController, :accept
    post "/invites/decline", InviteController, :decline
  end
end
