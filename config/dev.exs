import Config

config :messaging, Messaging.Auth.Jwt,
  identity_service_url: "http://localhost:2000",
  issuer: "Beat"

config :messaging, Messaging.Repo,
  username: "auth",
  password: "auth",
  hostname: "localhost",
  database: "messaging_db",
  show_sensitive_data_on_connection_error: true,
  pool_size: 10

config :messaging, Messaging.Redis.RClient,
  host: "localhost",
  port: 6379,
  database: 0

config :messaging, Messaging.Mongo,
  url: "mongodb://messaging:messaging@localhost:27017/messaging?authSource=admin",
  pool_size: 10

config :brod,
  clients: [
    kafka_client: [
      endpoints: [{"127.0.0.1", 9094}],
      auto_start_producers: true
    ]
  ]

config :messaging, MessagingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4000],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "DKQJCDhkhIJYwFMHfZhaawCyGgqRIKkLfGWydlICP2ct3Es0kyyiht5rse7Xn0Rm",
  watchers: []

config :messaging, dev_routes: true

config :logger, :console, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

config :phoenix, :plug_init_mode, :runtime

config :swoosh, :api_client, false
