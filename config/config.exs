import Config

config :messaging,
  ecto_repos: [Messaging.Repo],
  generators: [context_app: :messaging]

config :messaging,
  generators: [timestamp_type: :utc_datetime, binary_id: true]

config :phoenix_swagger, json_library: Jason

config :messaging, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: MessagingWeb.Router
    ]
  }

config :messaging, MessagingWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [json: MessagingWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: Messaging.PubSub,
  live_view: [signing_salt: "L/PfUi3h"]

config :messaging, Messaging.Mailer, adapter: Swoosh.Adapters.Local

config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :phoenix, :json_library, Jason

import_config "#{config_env()}.exs"
