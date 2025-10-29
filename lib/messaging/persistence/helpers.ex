defmodule Messaging.Persistence.Helpers do
  @uuid_regex ~r/^[0-9a-f]{8}-[0-9a-f]{4}-[0-5][0-9a-f]{3}-[089ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  @email_regex ~r/^\S+@\S+\.\S+$/

  def generate_ulid, do: Ulid.generate(System.system_time(:millisecond))

  def validate_uuid(cast, attr),
    do:
      cast
      |> Ecto.Changeset.validate_format(attr, @uuid_regex,
        message: "Messaging.Validation.InvalidUUID.Description"
      )

  def validate_email(cast, attr),
    do:
      cast
      |> Ecto.Changeset.validate_format(attr, @email_regex,
        message: "Messaging.Validation.InvalidEmail.Description"
      )
end
