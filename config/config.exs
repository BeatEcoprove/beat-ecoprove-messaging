# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :messaging,
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :messaging, Messaging.Auth,
  identity_service_url: System.get_env("IDENTITY_URL"),
  issuer: "Beat"

# Configures the endpoint
config :messaging, MessagingWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MessagingWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Messaging.PubSub,
  live_view: [signing_salt: "+4CNk5zR"]

# Redis configuration
config :messaging, :pubsub,
  adapter: Phoenix.PubSub.Redis,
  url: System.get_env("REDIS_URL"),
  pool_size: System.get_env("REDIS_POLL_SIZE"),
  namespace: System.get_env("REDIS_NAMESPACE")

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
