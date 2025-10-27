defmodule MessagingWeb.Swagger.MemberSwagger do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Member:
        swagger_schema do
          title("Member")
          description("A group member")

          properties do
            id(:string, "Member ID", required: true)
            user_id(:string, "User ID", required: true)
            group_id(:string, "Group ID", required: true)
            username(:string, "Username")
            email(:string, "Email address")
            joined_at(:string, "When the member joined", format: :datetime)
            is_active(:boolean, "Whether the member is active")
          end
        end,
      Role:
        swagger_schema do
          title("Role")
          description("A member's role in a group")

          properties do
            id(:string, "Role ID", required: true)
            name(:string, "Role name", required: true, enum: ["admin", "moderator", "member"])
            permissions(:array, "List of permissions", items: %{type: :string})
          end
        end,
      ChangeRoleResponse:
        swagger_schema do
          title("Change Role Response")
          description("Response when changing a member's role")

          properties do
            member(Schema.ref(:Member))
            role(Schema.ref(:Role))
          end
        end,
      ChangeRoleInput:
        swagger_schema do
          title("Change Role Input")
          description("Parameters for changing a member's role")

          properties do
            group_id(:string, "Group ID", required: true)
            name(:string, "New role name", required: true, enum: ["admin", "moderator", "member"])
          end
        end,
      KickMemberInput:
        swagger_schema do
          title("Kick Member Input")
          description("Parameters for kicking a member from a group")

          properties do
            group_id(:string, "Group ID", required: true)
            member_id(:string, "Member ID to kick", required: true)
          end
        end,
      KickMemberResponse:
        swagger_schema do
          title("Kick Member Response")
          description("Response when kicking a member")

          properties do
            member(Schema.ref(:Member))
            message(:string, "Success message")
          end
        end,
      Error:
        swagger_schema do
          title("Error")
          description("Error response")

          properties do
            error(:string, "Error message", required: true)
          end
        end
    }
  end
end
