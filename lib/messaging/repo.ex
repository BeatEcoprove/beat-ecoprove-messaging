defmodule Messaging.Repo do
  use Ecto.Repo,
    otp_app: :messaging,
    adapter: Ecto.Adapters.Postgres

  def paginate_cursor(queryable, opts \\ []) do
    import Ecto.Query

    limit = Keyword.get(opts, :limit, 10)
    cursor_field = Keyword.get(opts, :cursor_field, :inserted_at)
    after_cursor = Keyword.get(opts, :after)
    before_cursor = Keyword.get(opts, :before)

    # Parse cursor
    after_cursor = parse_cursor(after_cursor, cursor_field)
    before_cursor = parse_cursor(before_cursor, cursor_field)

    sort_direction = if before_cursor, do: :asc, else: :desc

    query =
      queryable
      |> apply_cursor_filter(cursor_field, after_cursor, before_cursor)
      |> order_by([{^sort_direction, ^cursor_field}])
      |> limit(^(limit + 1))

    results = Messaging.Repo.all(query)
    has_more = length(results) > limit
    data = results |> Enum.take(limit) |> maybe_reverse(before_cursor)

    %{
      data: data,
      next_cursor: encode_cursor(List.last(data), cursor_field),
      prev_cursor: encode_cursor(List.first(data), cursor_field),
      has_more: has_more
    }
  end

  defp apply_cursor_filter(queryable, cursor_field, after_cursor, before_cursor) do
    import Ecto.Query
    require Logger

    cond do
      after_cursor ->
        where(queryable, [x], field(x, ^cursor_field) < ^after_cursor)

      before_cursor ->
        where(queryable, [x], field(x, ^cursor_field) > ^before_cursor)

      true ->
        queryable
    end
  end

  defp parse_cursor(nil, _), do: nil

  defp parse_cursor(cursor, :inserted_at) when is_binary(cursor) do
    # Handle both NaiveDateTime and DateTime formats
    case NaiveDateTime.from_iso8601(cursor) do
      {:ok, datetime} ->
        datetime

      {:error, _} ->
        case DateTime.from_iso8601(cursor) do
          {:ok, datetime, _} -> DateTime.to_naive(datetime)
          _ -> nil
        end
    end
  end

  defp parse_cursor(cursor, _), do: cursor

  defp encode_cursor(nil, _), do: nil

  defp encode_cursor(record, cursor_field) do
    case Map.get(record, cursor_field) do
      %NaiveDateTime{} = dt -> NaiveDateTime.to_iso8601(dt)
      %DateTime{} = dt -> DateTime.to_iso8601(dt)
      other -> other
    end
  end

  defp maybe_reverse(data, nil), do: data
  defp maybe_reverse(data, _before_cursor), do: Enum.reverse(data)
end
