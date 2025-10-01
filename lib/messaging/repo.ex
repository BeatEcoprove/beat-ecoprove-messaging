defmodule Messaging.Repo do
  use Ecto.Repo,
    otp_app: :messaging,
    adapter: Ecto.Adapters.Postgres
end
