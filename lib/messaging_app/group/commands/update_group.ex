defmodule MessagingApp.Group.Commands.UpdateGroup do
  alias Messaging.Persistence.Repos.GroupRepo
  alias MessagingApp.Group.Inputs.UpdateGroupInput

  def call(public_id, input = %UpdateGroupInput{}) do
    input = Map.from_struct(input)

    with {:ok, group} <- get_group(public_id),
         {:ok} <- is_input_valid?(input),
         {:ok, updated_group} <- GroupRepo.update(group, input) do
      {:ok, updated_group}
    else
      {:error, reason} ->
        {:error, reason}
    end
  end

  defp is_input_valid?(input),
    do: Enum.all?(input, fn {_k, v} -> is_nil(v) end) |> check_input_size()

  defp check_input_size(false), do: {:ok}
  defp check_input_size(true), do: {:error, :group_wrong_input}

  defp get_group(public_id) do
    case GroupRepo.get_by_public_id(public_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
