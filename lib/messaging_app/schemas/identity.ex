defmodule MessagingApp.Schemas.Identity do
  @enforce_keys [:id, :email, :role, :scope]
  defstruct [:id, :email, :role, :scope]

  @type t :: %__MODULE__{
          id: String.t(),
          email: String.t(),
          role: String.t(),
          scope: [String.t()]
        }
end
