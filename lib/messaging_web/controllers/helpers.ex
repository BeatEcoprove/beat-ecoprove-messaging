defmodule MessagingWeb.Controllers.Helpers do
  def decode_pagination(pagination) do
    %{
      data: pagination.data,
      pagination: %{
        has_more: pagination.has_more,
        next_cursor: encode_cursor(pagination.next_cursor),
        prev_cursor: encode_cursor(pagination.prev_cursor)
      }
    }
  end

  def build_pagination_opts(params) do
    [
      limit: Map.get(params, "limit", "20") |> to_integer(),
      after: decode_cursor(Map.get(params, "after")),
      before: decode_cursor(Map.get(params, "before"))
    ]
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

  defp encode_cursor(nil), do: nil
  defp encode_cursor(%BSON.ObjectId{} = cursor), do: BSON.ObjectId.encode!(cursor)
  defp encode_cursor(cursor) when is_binary(cursor), do: cursor

  defp decode_cursor(nil), do: nil

  defp decode_cursor(cursor) when is_binary(cursor) do
    case BSON.ObjectId.decode(cursor) do
      {:ok, object_id} -> object_id
      :error -> nil
    end
  end

  defp decode_cursor(_), do: nil

  # Helper to convert string to integer safely
  defp to_integer(value) when is_integer(value), do: value

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      # default
      :error -> 20
    end
  end

  defp to_integer(_), do: 20
end
