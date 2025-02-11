defmodule MessagingWeb.Router do
  use MessagingWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MessagingWeb do
    pipe_through :api
  end
end
