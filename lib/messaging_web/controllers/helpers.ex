defmodule MessagingWeb.Controllers.Helpers do
  @default_limit 20
  @max_limit 100

  @doc """
  Decodes pagination result for JSON response
  """
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

  @doc """
  Builds pagination options from request params
  """
  def build_pagination_opts(params) do
    [
      limit: get_limit(params),
      after: decode_cursor(Map.get(params, "after")),
      before: decode_cursor(Map.get(params, "before"))
    ]
    |> Enum.reject(fn {_k, v} -> is_nil(v) end)
  end

  # Encode cursor to string for JSON response
  defp encode_cursor(nil), do: nil
  defp encode_cursor(%BSON.ObjectId{} = cursor), do: BSON.ObjectId.encode!(cursor)
  defp encode_cursor(cursor) when is_binary(cursor), do: cursor

  # Decode cursor from request params
  defp decode_cursor(nil), do: nil

  defp decode_cursor(cursor) when is_binary(cursor) do
    case BSON.ObjectId.decode(cursor) do
      {:ok, object_id} -> object_id
      :error -> nil
    end
  end

  defp decode_cursor(_), do: nil

  # Get limit with bounds checking
  defp get_limit(params) do
    params
    |> Map.get("limit", @default_limit)
    |> to_integer()
    |> clamp_limit()
  end

  # Convert string to integer safely
  defp to_integer(value) when is_integer(value), do: value

  defp to_integer(value) when is_binary(value) do
    case Integer.parse(value) do
      {int, _} -> int
      :error -> @default_limit
    end
  end

  defp to_integer(_), do: @default_limit

  # Ensure limit is within acceptable bounds
  defp clamp_limit(limit) when limit < 1, do: @default_limit
  defp clamp_limit(limit) when limit > @max_limit, do: @max_limit
  defp clamp_limit(limit), do: limit
end
