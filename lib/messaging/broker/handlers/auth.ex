defmodule Messaging.Broker.Handlers.Auth do
  require Logger

  alias Messaging.Broker.Events
  alias Messaging.Persistence.Repos.UserRepo

  def handle(%{payload: %Events.ProfileCreatedEvent{} = event}) do
    case UserRepo.already_created?(event.profile_id) do
      false ->
        UserRepo.create(%{
          auth_id: event.auth_id,
          profile_id: event.profile_id,
          display_name: event.display_name,
          role: event.role
        })

      true ->
        Logger.info("Profile created > #{inspect(event.profile_id)}")
    end
  end
end
