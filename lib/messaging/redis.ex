defmodule Messaging.Redis.RClient do
  use GenServer

  alias Redix

  def start_link(_opts) do
    opts = Application.fetch_env!(:messaging, __MODULE__)
    GenServer.start_link(__MODULE__, opts, name: __MODULE__)
  end

  def set(key, value, exp \\ 1), do: GenServer.call(__MODULE__, {:set, key, value, exp})

  def get(key), do: GenServer.call(__MODULE__, {:get, key})

  @spec init(keyword()) :: {:ok, %{conn: pid()}}
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

  def handle_call({:set, key, value, exp}, _from, %{conn: conn} = state) do
    result =
      case Redix.command(conn, ["SET", key, value, "EX", Integer.to_string(exp)]) do
        {:ok, "OK"} ->
          :ok

        {:error, reason} ->
          {:error, reason}
      end

    {:reply, result, state}
  end

  def handle_call({:get, key}, _from, %{conn: conn} = state) do
    {:ok, value} = Redix.command(conn, ["GET", key])
    {:reply, value, state}
  end
end
