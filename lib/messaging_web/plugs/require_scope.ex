defmodule MessagingWeb.Plugs.RequireScope do
  import Plug.Conn
  import Phoenix.Controller

  alias MessagingWeb.Controllers.ErrorController

  def init(opts) do
    resource = Keyword.fetch!(opts, :resource)
    actions = Keyword.get(opts, :actions, []) |> Map.new()

    %{resource: Atom.to_string(resource), actions: actions}
  end

  def call(conn, %{resource: resource, actions: action_map}) do
    action = action_name(conn)
    permission = Map.get(action_map, action, action)
    required_scope = "#{resource}:#{permission}"
    current_user = conn.assigns[:current_user]

    if has_scope?(current_user, required_scope) do
      conn
    else
      conn
      |> ErrorController.call_unauthorized()
      |> halt()
    end
  end

  defp has_scope?(%{scope: scopes}, required_scope) when is_list(scopes) do
    required_scope in scopes
  end

  defp has_scope?(_, _), do: false
end
