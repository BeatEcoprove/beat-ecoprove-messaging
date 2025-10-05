defmodule Messaging.Redis do
  use GenServer

  alias Redix

  def start_link(_opts) do
    opts = Application.fetch_env!(:messaging, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def set(key, value), do: GenServer.call(__MODULE__, {:set, key, value})
  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  def init(opts) do
    host = Keyword.get(opts, :host, "localhost")
    port = Keyword.get(opts, :port, "6379")
    db = Keyword.get(opts, :db, 0)

    {:ok, conn} =
      Redix.start_link(
        host: host,
        port: port,
        database: db
      )

    {:ok, %{conn: conn}}
  end

  def handle_call({:set, key, value}, _from, conn) do
    Redix.command(conn, ["SET", key, value])
    {:reply, :ok, conn}
  end

  def handle_call({:get, key}, _from, conn) do
    {:ok, value} = Redix.command(conn, ["GET", key])
    {:reply, value, conn}
  end
end
