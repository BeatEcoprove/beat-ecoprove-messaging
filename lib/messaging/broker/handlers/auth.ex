defmodule Messaging.Broker.Handlers.Auth do
  alias Messaging.Broker.Events
  alias Messaging.Persistence.Repos.UserRepo

  def handle(%{payload: %Events.UserCreatedEvent{} = event}) do
    case UserRepo.already_created?(event.public_id) do
      false ->
        UserRepo.create(%{
          public_id: event.public_id,
          email: event.email,
          role: event.role
        })

      true ->
        IO.puts("user already registered")
    end
  end
end
