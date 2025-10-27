defmodule MessagingWeb.Swagger.GroupSwagger do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      GroupCreate:
        swagger_schema do
          title("Group Create Detail")
          description("Chat Group Detail")

          properties do
            id(:string, "Group ID", required: true)
            name(:string, "Group name", required: true)
            description(:string, "Group description")
            is_public(:boolean, "Whether the group is public", required: true)
            inserted_at(:date, "Insert date", required: true)
            sustainability_points(:float, "Sustainability Points", required: true)
            xp(:float, "Sustainability Points", required: true)
            avatar_url(:string, "Group Avatar", required: true)
          end
        end,
      Group:
        swagger_schema do
          title("Group")
          description("Chat Group Detail")

          properties do
            id(:string, "Group ID", required: true)
            name(:string, "Group name", required: true)
            description(:string, "Group description")
            is_public(:boolean, "Whether the group is public", required: true)
            inserted_at(:date, "Insert date", required: true)
            members(:array, "List of members of the group", items: :string)
            sustainability_points(:float, "Sustainability Points", required: true)
            xp(:float, "Sustainability Points", required: true)
            avatar_url(:string, "Group Avatar", required: true)
            member_count(:int, "Members Qty", required: true)
          end
        end,
      Groups:
        swagger_schema do
          title("Groups")

          properties do
            data(:array, "List of groups", items: Schema.ref(:Group))
            has_more(:bool, "Checks if there are more groups")
            next_cursor(:string, "next element")
            prev_cursor(:string, "prev element")
          end
        end,
      CreateGroupInput:
        swagger_schema do
          title("Create Group Input")

          properties do
            name(:string, "Group name", required: true)
            description(:string, "Group description")
            is_public(:boolean, "Whether the group is public", required: true)
          end
        end,
      UpdateGroupInput:
        swagger_schema do
          title("Update Group Input")

          properties do
            name(:string, "Group name")
            description(:string, "Group description")
            is_public(:boolean, "Whether the group is public")
          end
        end
    }
  end
end
