defmodule Messaging.Flow.Error do
  @enforce_keys [:type, :title, :status, :detail]
  defstruct [:type, :title, :status, :detail, :instance, :errors]

  @type t :: %__MODULE__{
          type: String.t(),
          title: String.t(),
          status: integer(),
          detail: String.t(),
          instance: String.t() | nil,
          errors: map() | nil
        }
end

defimpl Jason.Encoder, for: Messaging.Flow.Error do
  def encode(%Messaging.Flow.Error{} = error, opts) do
    base_map = %{
      type: error.type,
      title: error.title,
      status: error.status,
      detail: error.detail,
      instance: error.instance
    }

    map_with_errors =
      case error.errors do
        nil -> base_map
        [] -> base_map
        %{} = errs when map_size(errs) == 0 -> base_map
        errs -> Map.put(base_map, :errors, errs)
      end

    Jason.Encode.map(map_with_errors, opts)
  end
end
