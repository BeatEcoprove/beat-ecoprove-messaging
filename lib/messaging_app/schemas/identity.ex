defmodule MessagingApp.Schemas.Identity do
  @enforce_keys [:id, :email]
  defstruct [:id, :email, role: "client"]

  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t(),
          role: String.t()
        }
end
