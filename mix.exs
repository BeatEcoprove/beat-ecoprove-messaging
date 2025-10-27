defmodule Messaging.MixProject do
  use Mix.Project

  def project do
    [
      app: :messaging,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  def application do
    [
      mod: {Messaging.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:phoenix_swagger, "~> 0.8.5"},
      {:phoenix_pubsub_redis, "~> 3.0"},
      {:mongodb_driver, "~> 1.5.0"},
      {:redix, "~> 1.1"},
      {:jose, "~> 1.11"},
      {:joken_jwks, "~> 1.7"},
      {:joken, "~> 2.6"},
      {:httpoison, "~> 2.2"},
      {:ulid, "~> 0.2.0"},
      {:postgrex, "~> 0.20.0"},
      {:ecto_sql, "~> 3.13"},
      {:brod, "~> 4.4"},
      {:phoenix_view, "~> 2.0"},
      {:phoenix, "~> 1.7.21"},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 1.0"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.26"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"}
    ]
  end

  defp aliases do
    [
      setup: ["deps.get"],
      generate: ["phx.swagger.generate"],
      serve: ["ecto.migrate", "phx.server"],
      reset: ["ecto.rollback"]
    ]
  end
end
