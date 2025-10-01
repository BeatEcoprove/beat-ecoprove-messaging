defmodule MessagingWeb.Controllers.ErrorController do
  alias Messaging.Flow
  alias Messaging.Flow.Errors.{Group}
  use MessagingWeb, :controller

  @errors Map.merge(Group.register(), %{})

  defp render_error(app_error, conn) do
    app_error = Map.put(app_error, :instance, conn.request_path)

    conn
    |> put_status(app_error.status)
    |> put_view(MessagingWeb.ErrorJSON)
    |> render("#{app_error.status}.json", error: app_error)
  end

  def call_unauthorized(conn) do
    Flow.unauthorized()
    |> render_error(conn)
    |> halt()
  end

  def call(conn, {:error, error}) when is_atom(error) do
    search_errors(error)
    |> render_error(conn)
  end

  def call(conn, {:error, %Ecto.Changeset{errors: errors}}) do
    errors =
      Enum.into(errors, %{}, fn {field, {message, _}} ->
        {field, message}
      end)

    Messaging.Flow.bad_request(errors)
    |> render_error(conn)
  end

  def call(conn, _opts) do
    conn
    |> put_status(:internal_server_error)
    |> put_view(MessagingWeb.ErrorJSON)
    |> render("500.json", error: Flow.internal_server_error())
  end

  defp search_errors(error) when is_atom(error),
    do: Map.get(@errors, error, Messaging.Flow.internal_server_error())
end
