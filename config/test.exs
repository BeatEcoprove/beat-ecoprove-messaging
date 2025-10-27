import Config

config :messaging, MessagingWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: 4002],
  secret_key_base: "nOh3uUj6xN+E1SnIgCa6IIGgv2mBdZRe+972iKjPlI3k8cNWveQmBC8VmxcwvQEn",
  server: false

config :messaging, Messaging.Mailer, adapter: Swoosh.Adapters.Test

config :swoosh, :api_client, false

config :logger, level: :warning

config :phoenix, :plug_init_mode, :runtime
