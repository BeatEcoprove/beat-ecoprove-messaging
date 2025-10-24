defmodule Messaging.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MessagingWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:messaging, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Messaging.PubSub},
      {Finch, name: Messaging.Finch},
      MessagingWeb.Endpoint,
      Messaging.Repo,
      Messaging.Redis.RClient,
      Messaging.Mongo,
      Messaging.Broker.EventBus
    ]

    opts = [strategy: :one_for_one, name: Messaging.Supervisor]
    Supervisor.start_link(children, opts)
  end

  @impl true
  def config_change(changed, _new, removed) do
    MessagingWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
