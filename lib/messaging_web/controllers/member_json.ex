defmodule MessagingWeb.Controllers.MemberJSON do
  alias Messaging.Persistence.Schemas.Member

  def render("kick.json", %{member: member = %Member{}}) do
    %{
      id: member.user.profile_id,
      status: "kicked"
    }
  end

  def render("change_role.json", %{member: member = %Member{}, role: role}) do
    %{
      id: member.user.profile_id,
      role: role
    }
  end
end
