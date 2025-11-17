defmodule MessagingWeb.Controllers.GroupController do
  use MessagingWeb, :controller
  use PhoenixSwagger

  alias MessagingWeb.Swagger.GroupSwagger
  alias MessagingWeb.Controllers.Helpers
  alias MessagingApp.Group.Inputs.UpdateGroupInput
  alias MessagingApp.Group.Inputs.CreateGroupInput

  plug MessagingWeb.Plugs.RequireScope,
    resource: :group,
    actions: [
      index: :view,
      show: :view,
      fetch_public: :view
    ]

  def swagger_definitions, do: GroupSwagger.swagger_definitions()

  swagger_path :index do
    get("/groups")
    summary("List groups")
    description("Get a paginated list of groups the current user belongs to")
    produces("application/json")

    parameter(:limit, :query, :integer, "Limit Group Number", example: 1)
    parameter(:before, :query, :string, "Insert At", example: "2025-10-27T18:50:32")
    parameter(:after, :query, :string, "Insert At", example: "2025-10-27T18:50:32")

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Groups))
    response(401, "Unauthorized")
  end

  @doc """
  Get user belonging groups
  """
  def index(conn = %{assigns: %{current_user: current_user}}, params) do
    opts = Helpers.build_pagination_opts(params)
    groups = MessagingApp.Group.get_all(current_user.id, opts)

    conn
    |> put_status(:ok)
    |> render("index.json", paginate: groups)
  end

  swagger_path :fetch_public do
    get("/groups/public")
    summary("List of Public Groups")
    description("Get a paginated list of groups the current user doesn't belongs to")
    produces("application/json")

    parameter(:limit, :query, :integer, "Limit Group Number", example: 1)
    parameter(:before, :query, :string, "Insert At", example: "2025-10-27T18:50:32")
    parameter(:after, :query, :string, "Insert At", example: "2025-10-27T18:50:32")

    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Groups))
    response(401, "Unauthorized")
  end

  @doc """
  Get All Public Groups, that the user doesn't belong to
  """
  def fetch_public(conn = %{assigns: %{current_user: current_user}}, params) do
    IO.puts("Hello World!,,,,,,")
    opts = Helpers.build_pagination_opts(params)
    groups = MessagingApp.Group.get_all(current_user.id, opts)

    conn
    |> put_status(:ok)
    |> render("index.json", paginate: groups)
  end

  swagger_path :show do
    get("/groups/{id}")
    summary("Get group details")
    produces("application/json")

    parameter(:id, :path, :string, "Group ID", required: true)
    security([%{Bearer: []}])

    response(200, "Success", Schema.ref(:Group))
    response(404, "Group not found")
  end

  @doc """
  Get detail from a specific group
  """
  def show(conn = %{assigns: %{current_user: _current_user}}, %{"id" => id}) do
    case MessagingApp.Group.get_details(%{group_id: id}) do
      {:ok, group_detail} ->
        conn
        |> put_status(:ok)
        |> render("group.json", group: group_detail)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :create do
    post("/groups")
    summary("Create a group")
    produces("application/json")
    consumes("application/json")

    parameter(:body, :body, Schema.ref(:CreateGroupInput), "Group parameters", required: true)
    security([%{Bearer: []}])

    response(201, "Group created successfully", Schema.ref(:GroupCreate))
    response(400, "Invalid input")
  end

  @doc """
  Create Group
  """
  def create(conn = %{assigns: %{current_user: current_user}}, payload) do
    input = %CreateGroupInput{
      name: payload["name"],
      description: payload["description"],
      is_public: payload["is_public"],
      creator: current_user
    }

    case MessagingApp.Group.create_group(input) do
      {:ok, group} ->
        conn
        |> put_status(:created)
        |> render("group.json", group: group)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :delete do
    PhoenixSwagger.Path.delete("/groups/{id}")
    summary("Delete a group")
    produces("application/json")

    parameter(:id, :path, :string, "Group ID", required: true)
    security([%{Bearer: []}])

    response(200, "Group deleted successfully", Schema.ref(:Group))
    response(404, "Group not found")
  end

  def delete(conn, %{"id" => id}) do
    case MessagingApp.Group.delete_group(%{group_id: id}) do
      {:ok, group_detail} ->
        conn
        |> put_status(:ok)
        |> render("group.json", group: group_detail)

      {:error, reason} ->
        {:error, reason}
    end
  end

  swagger_path :update do
    put("/groups/{id}")
    summary("Update a group")
    produces("application/json")

    parameter(:id, :path, :string, "Group ID", required: true)
    parameter(:body, :body, Schema.ref(:UpdateGroupInput), "Updated parameters", required: true)
    security([%{Bearer: []}])

    response(200, "Group updated successfully", Schema.ref(:Group))
    response(404, "Group not found")
  end

  def update(conn, %{"id" => id} = payload) do
    input = %UpdateGroupInput{
      name: payload["name"],
      description: payload["description"],
      is_public: payload["is_public"]
    }

    case MessagingApp.Group.update_group(%{id: id, payload: input}) do
      {:ok, group} ->
        conn
        |> put_status(:ok)
        |> render("group.json", group: group)

      {:error, reason} ->
        {:error, reason}
    end
  end
end
