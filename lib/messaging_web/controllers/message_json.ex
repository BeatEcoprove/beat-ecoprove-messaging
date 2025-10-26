defmodule MessagingWeb.Controllers.MessageJSON do
  alias MessagingWeb.Controllers.Helpers

  def render("messages.json", %{paginate: data}) do
    Helpers.decode_pagination(data)
  end
end
