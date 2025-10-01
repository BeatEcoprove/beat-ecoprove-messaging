defmodule Messaging.Flow.Response do
  @enforce_keys [:data]
  defstruct [:data, :meta]

  @type t :: %__MODULE__{
          data: map() | list(),
          meta: map() | nil
        }
end

defimpl Jason.Encoder, for: Messaging.Flow.Response do
  def encode(%Messaging.Flow.Response{} = error, opts) do
    base_map = %{
      data: error.data
    }

    map_with_meta =
      case error.meta do
        nil -> base_map
        [] -> base_map
        %{} = meta when map_size(meta) == 0 -> base_map
        meta -> Map.put(base_map, :meta, meta)
      end

    Jason.Encode.map(map_with_meta, opts)
  end
end
