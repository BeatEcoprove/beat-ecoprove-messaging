defmodule MessagingWeb.Swagger.InviteSwagger do
  use PhoenixSwagger

  def swagger_definitions do
    %{
      Invite:
        swagger_schema do
          title("Invite")
          description("A group invitation")

          properties do
            id(:string, "Invite ID", required: true)
            group_id(:string, "Group ID", required: true)
            inviter_id(:string, "ID of the user who sent the invite", required: true)
            invitee_id(:string, "ID of the user who received the invite", required: true)

            role(:string, "Role assigned to the invitee",
              required: true,
              enum: ["admin", "member", "moderator"]
            )

            token(:string, "Invitation token", required: true)
            status(:string, "Invite status", enum: ["pending", "accepted", "declined"])
            created_at(:string, "Creation timestamp", format: :datetime)
            updated_at(:string, "Last update timestamp", format: :datetime)
          end
        end,
      CreateInviteInput:
        swagger_schema do
          title("Create Invite Input")
          description("Parameters for creating a group invitation")

          properties do
            invitee_id(:string, "ID of the user to invite", required: true)

            role(:string, "Role to assign",
              required: true,
              enum: ["admin", "member", "moderator"]
            )
          end
        end,
      AcceptInviteInput:
        swagger_schema do
          title("Accept Invite Input")
          description("Parameters for accepting an invitation")

          properties do
            token(:string, "Invitation token", required: true)
          end
        end,
      DeclineInviteInput:
        swagger_schema do
          title("Decline Invite Input")
          description("Parameters for declining an invitation")

          properties do
            token(:string, "Invitation token", required: true)
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
