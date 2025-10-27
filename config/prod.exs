import Config

config :swoosh, api_client: Swoosh.ApiClient.Finch, finch_name: Messaging.Finch

config :swoosh, local: false

config :logger, level: :info
