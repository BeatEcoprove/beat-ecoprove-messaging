defmodule MessagingWeb.Controllers.GroupJSON do
  alias Messaging.Persistence.Schemas.Group

  def render("group.json", %{group: group = %Group{}}) do
    %{
      id: group.public_id,
      name: group.name,
      description: group.description,
      sustainability_points: group.sustainability_points,
      xp: group.xp,
      is_public: group.is_public,
      inserted_at: group.inserted_at,
      updated_at: group.updated_at
    }
  end

  def render("index.json", %{groups: groups}) when is_list(groups) do
    Enum.map(groups, &render("group.json", %{group: &1}))
  end
end
