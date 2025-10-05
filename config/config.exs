# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :messaging,
  ecto_repos: [Messaging.Repo],
  generators: [context_app: :messaging]

config :messaging,
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :messaging, Messaging.Auth.Jwt,
  identity_service_url: System.get_env("IDENTITY_URL"),
  issuer: "Beat"

config :messaging, Messaging.Redis.RClient,
  host: "localhost",
  port: 6379,
  database: 0

config :brod,
  clients: [
    kafka_client: [
      endpoints: [{"127.0.0.1", 9092}],
      auto_start_producers: true
    ]
  ]

# Configures the endpoint
config :messaging, MessagingWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MessagingWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Messaging.PubSub,
  live_view: [signing_salt: "L/PfUi3h"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :messaging, Messaging.Mailer, adapter: Swoosh.Adapters.Local

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
