defmodule MessagingWeb.Controllers.GroupController do
  use MessagingWeb, :controller

  alias MessagingApp.Group.Inputs.UpdateGroupInput
  alias MessagingApp.Group.Inputs.CreateGroupInput

  plug MessagingWeb.Plugs.RequireScope,
    resource: :group,
    actions: [
      index: :view,
      show: :view
    ]

  @doc """
  Get user belonging groups
  """
  def index(conn = %{assigns: %{current_user: current_user}}, _params) do
    groups = MessagingApp.Group.get_all(%{user_id: current_user.id})

    conn
    |> put_status(:ok)
    |> render("index.json", groups: groups)
  end

  @doc """
  Get detail from a specific group
  """
  def show(conn = %{assigns: %{current_user: _current_user}}, %{"id" => id}) do
    IO.puts("#{inspect(id)}")

    case MessagingApp.Group.get_details(%{group_id: id}) do
      {:ok, group_detail} ->
        conn
        |> put_status(:ok)
        |> render("group.json", group: group_detail)

      {:error, reason} ->
        {:error, reason}
    end
  end

  @doc """
  Create Group
  """
  def create(conn = %{assigns: %{current_user: current_user}}, %{"payload" => payload}) do
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

  def update(conn, %{"id" => id, "payload" => payload}) do
    input = %UpdateGroupInput{
      name: payload["name"],
      description: payload["description"],
      is_public: payload["is_public"]
    }

    IO.puts("#{inspect(input)}")

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
