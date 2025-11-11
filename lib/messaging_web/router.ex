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

  scope "/swagger" do
    forward "/", PhoenixSwagger.Plug.SwaggerUI, otp_app: :messaging, swagger_file: "swagger.json"
  end

  def swagger_info do
    %{
      schemes: ["http", "https"],
      basePath: "/api/v1",
      info: %{
        version: "1.0",
        title: "Messaging Service",
        description: "This service is responsable for chats and emails",
        termsOfService: "Open for public",
        contact: %{
          name: "Beat Ecoprove",
          email: "beatecoprove@gmail.com"
        }
      },
      securityDefinitions: %{
        Bearer: %{
          type: "apiKey",
          name: "Authorization",
          description: "API Token must be provided via `Authorization: Bearer ` header",
          in: "header"
        }
      },
      consumes: ["application/json"],
      produces: ["application/json"]
    }
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
