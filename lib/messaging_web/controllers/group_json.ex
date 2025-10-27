defmodule MessagingWeb.Controllers.GroupJSON do
  alias Messaging.Persistence.Schemas.Group

  def render("group.json", %{group: group = %Group{}}) do
    payload = %{
      id: group.public_id,
      name: group.name,
      description: group.description,
      sustainability_points: group.sustainability_points,
      xp: group.xp,
      is_public: group.is_public,
      inserted_at: group.inserted_at,
      avatar_url: group.avatar_img
    }

    case Group.get_members_count(group) do
      {:ok, count} ->
        member_ids = Enum.map(group.members || [], fn member -> member.id end)

        payload
        |> Map.put(:member_count, count)
        |> Map.put(:members, member_ids)

      {:error, _reason} ->
        payload
    end
  end

  def render("index.json", %{paginate: data}) do
    formatted_data =
      Map.update!(data, :data, fn groups ->
        Enum.map(groups, &render("group.json", %{group: &1}))
      end)

    formatted_data
  end
end
