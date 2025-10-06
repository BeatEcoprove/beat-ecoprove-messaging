defmodule MessagingWeb.Controllers.MemberJSON do
  alias Messaging.Persistence.Schemas.Member

  def render("kick.json", %{member: member = %Member{}}) do
    %{
      id: member.user.public_id,
      status: "kicked"
    }
  end
end
