defmodule MessagingWeb.Endpoint do
  use Phoenix.Endpoint, otp_app: :messaging

  @session_options [
    store: :cookie,
    key: "_messaging_key",
    signing_salt: "CfOEKNuU",
    same_site: "Lax"
  ]

  socket "/socket", MessagingWeb.UserSocket,
    websocket: [
      connect_info: [:x_headers, :peer_data]
    ],
    longpoll: false

  socket "/live", Phoenix.LiveView.Socket,
    websocket: [connect_info: [session: @session_options]],
    longpoll: [connect_info: [session: @session_options]]

  plug Plug.Static,
    at: "/",
    from: :messaging,
    gzip: false,
    only: MessagingWeb.static_paths()

  if code_reloading? do
    plug Phoenix.CodeReloader
  end

  plug Phoenix.LiveDashboard.RequestLogger,
    param_key: "request_logger",
    cookie_key: "request_logger"

  plug Plug.RequestId
  plug Plug.Telemetry, event_prefix: [:phoenix, :endpoint]

  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Phoenix.json_library()

  plug Plug.MethodOverride
  plug Plug.Head
  plug Plug.Session, @session_options
  plug MessagingWeb.Router
end
