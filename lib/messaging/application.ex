defmodule Messaging.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children = [
      MessagingWeb.Telemetry,
      {DNSCluster, query: Application.get_env(:messaging, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Messaging.PubSub},
      Messaging.Presence,
      MessagingWeb.Endpoint,
      Messaging.Auth.TokenWatcher
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
