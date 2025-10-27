import Config

if System.get_env("PHX_SERVER") do
  config :messaging, MessagingWeb.Endpoint, server: true
end

if config_env() == :prod do
  secret_key_base =
    System.get_env("SECRET_KEY_BASE") ||
      raise """
      environment variable SECRET_KEY_BASE is missing.
      You can generate one by calling: mix phx.gen.secret
      """

  host = System.get_env("PHX_HOST") || "localhost"
  port = String.to_integer(System.get_env("BEAT_MESSASSING_SERVER") || "4000")

  config :messaging, :dns_cluster_query, System.get_env("DNS_CLUSTER_QUERY")

  config :messaging, MessagingWeb.Endpoint,
    url: [host: host, port: 443, scheme: "https"],
    http: [
      ip: {0, 0, 0, 0, 0, 0, 0, 0},
      port: port
    ],
    secret_key_base: secret_key_base

  config :messaging, Messaging.Auth.Jwt,
    identity_service_url:
      System.get_env("BEAT_IDENTITY_SERVER") ||
        raise("""
        environment variable BEAT_IDENTITY_SERVER is missing.
        """),
    issuer: "Beat"

  config :messaging, Messaging.Redis.RClient,
    host: System.get_env("REDIS_HOST") || "localhost",
    port: String.to_integer(System.get_env("REDIS_PORT") || "6379"),
    database: String.to_integer(System.get_env("REDIS_DB") || "0")

  mongo_username = System.get_env("MONGO_USERNAME") || "messaging"
  mongo_password = System.get_env("MONGO_PASSWORD") || "messaging"
  mongo_host = System.get_env("MONGO_HOST") || "localhost"
  mongo_port = String.to_integer(System.get_env("MONGO_PORT") || "27017")
  mongo_db = System.get_env("MONGO_DB") || "messaging"

  config :messaging, Messaging.Mongo,
    url:
      "mongodb://#{mongo_username}:#{mongo_password}@#{mongo_host}:#{mongo_port}/#{mongo_db}?authSource=admin",
    pool_size: 10

  kafka_host = System.get_env("KAFKA_HOST") || "127.0.0.1"
  kafka_port = String.to_integer(System.get_env("KAFKA_PORT") || "9094")

  config :brod,
    clients: [
      kafka_client: [
        endpoints: [{String.to_charlist(kafka_host), kafka_port}],
        auto_start_producers: true
      ]
    ]

  config :messaging, Messaging.Repo,
    username: System.get_env("POSTGRES_USER") || "messaging",
    password: System.get_env("POSTGRES_PASSWORD") || "messaging",
    hostname: System.get_env("MONGO_USERNAME") || "localhost",
    database: System.get_env("POSTGRES_HOST") || "messaging_db",
    port: String.to_integer(System.get_env("POSTGRES_PORT") || "5432"),
    show_sensitive_data_on_connection_error: true,
    pool_size: 10
end
