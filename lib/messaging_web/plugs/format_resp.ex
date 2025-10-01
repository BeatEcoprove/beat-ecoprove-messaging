defmodule MessagingWeb.Plugs.FormatResponse do
  import Plug.Conn

  alias Messaging.Flow.Response

  def init(default), do: default

  def call(conn, _opts), do: register_before_send(conn, &format_response/1)

  defp format_response(conn) do
    if is_json_request?(conn) do
      conn
      |> forward_connection()
    else
      conn
    end
  end

  defp forward_connection(conn) do
    body = IO.iodata_to_binary(conn.resp_body)

    if String.contains?(body, ~s("data":)) do
      conn
    else
      wrapped = Jason.encode!(%Response{data: Jason.Fragment.new(body)})
      %{conn | resp_body: wrapped}
    end
  end

  defp is_json_request?(conn),
    do:
      get_resp_header(conn, "content-type")
      |> Enum.any?(&String.contains?(&1, "application/json"))
end
