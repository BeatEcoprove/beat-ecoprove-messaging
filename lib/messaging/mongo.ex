defmodule Messaging.Mongo do
  use Mongo.Repo,
    otp_app: :messaging,
    topology: :mongo

  def paginate_cursor(collection, filter \\ %{}, opts \\ []) do
    limit = Keyword.get(opts, :limit, 10)
    cursor_field = Keyword.get(opts, :cursor_field, "_id")
    after_cursor = Keyword.get(opts, :after)
    before_cursor = Keyword.get(opts, :before)
    sort_direction = if before_cursor, do: 1, else: -1

    cursor_filter =
      cond do
        after_cursor -> Map.put(filter, cursor_field, %{"$lt" => after_cursor})
        before_cursor -> Map.put(filter, cursor_field, %{"$gt" => before_cursor})
        true -> filter
      end

    stream_result =
      Mongo.find(:mongo, collection, cursor_filter,
        limit: limit + 1,
        sort: %{cursor_field => sort_direction}
      )

    case stream_result do
      stream ->
        results = Enum.to_list(stream)
        has_more = length(results) > limit
        data = Enum.take(results, limit)
        data = if before_cursor, do: Enum.reverse(data), else: data

        {:ok,
         %{
           data: data,
           next_cursor: if(has_more and length(data) > 0, do: List.last(data)["_id"]),
           prev_cursor: if(length(data) > 0, do: List.first(data)["_id"]),
           has_more: has_more
         }}

      {:error, error} ->
        {:error, error}
    end
  end
end
