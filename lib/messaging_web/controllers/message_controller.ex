defmodule MessagingWeb.Controllers.MessageController do
  use MessagingWeb, :controller
  use PhoenixSwagger

  alias MessagingApp.Messages
  alias MessagingWeb.Swagger.MessageSwagger
  alias MessagingWeb.Controllers.Helpers

  plug MessagingWeb.Plugs.RequireMembership

  plug MessagingWeb.Plugs.RequireScope,
    resource: :message,
    actions: [
      index: :view,
      show: :view
    ]

  def swagger_definitions, do: MessageSwagger.swagger_definitions()

  swagger_path :index do
    get("/groups/{group_id}/messages")
    summary("List group messages")
    description("Get a paginated list of messages in a group. Requires group membership.")
    produces("application/json")

    parameter(:group_id, :path, :string, "Group ID", required: true, example: "group456")
    parameter(:page, :query, :integer, "Page number", example: 1)

    parameter(:page_size, :query, :integer, "Number of items per page (default: 20, max: 100)",
      example: 20
    )

    parameter(:before, :query, :string, "Get messages before this timestamp (ISO 8601)",
      required: false
    )

    parameter(:after, :query, :string, "Get messages after this timestamp (ISO 8601)",
      required: false
    )

    parameter(:search, :query, :string, "Search messages by content", required: false)

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Messages))
    response(401, "Unauthorized", Schema.ref(:Error))

    response(
      403,
      "Forbidden - not a member of this group or insufficient permissions",
      Schema.ref(:Error)
    )

    response(404, "Group not found", Schema.ref(:Error))
  end

  def index(conn = %{assigns: %{group: group}}, params) do
    opts = Helpers.build_pagination_opts(params)

    case Messages.get_all_messages(group.public_id, opts) do
      {:ok, paginated_data} ->
        conn
        |> put_status(:ok)
        |> render("messages.json", paginate: paginated_data)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :show do
    get("/messages/{id}")
    summary("Get message details")

    description(
      "Get detailed information about a specific message. Requires membership in the message's group."
    )

    produces("application/json")

    parameter(:id, :path, :string, "Message ID", required: true, example: "msg123")

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Message))
    response(401, "Unauthorized", Schema.ref(:Error))

    response(
      403,
      "Forbidden - not a member of this group or insufficient permissions",
      Schema.ref(:Error)
    )

    response(404, "Message not found", Schema.ref(:Error))
  end

  def show(conn, %{"id" => message_id}) do
    case Messages.get(message_id) do
      {:ok, message} ->
        conn
        |> put_status(:ok)
        |> render("message.json", message: message)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
