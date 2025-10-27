defmodule MessagingWeb.Plugs.RequireMembership do
  import Plug.Conn

  alias MessagingWeb.Controllers.ErrorController
  alias Messaging.Persistence.Repos.{GroupRepo, MemberRepo}

  def init(opts), do: opts

  def call(conn, _opts) do
    group_id = conn.params["group_id"]
    user_id = conn.assigns.current_user.id

    with {:ok, group} <- get_group(group_id),
         {:ok, member} <- get_member(user_id, group.id) do
      conn
      |> assign(:group, group)
      |> assign(:member, member)
      |> assign(:membership_verified, true)
    else
      {:error, error} ->
        conn
        |> ErrorController.call({:error, error})
        |> halt()
    end
  end

  defp get_member(member_id, group_id) do
    case MemberRepo.get_by_public_id(member_id, group_id) do
      nil ->
        {:error, :member_not_found}

      member ->
        {:ok, member}
    end
  end

  def get_group(group_id) do
    case GroupRepo.get_by_public_id(group_id) do
      nil ->
        {:error, :group_not_found}

      group ->
        {:ok, group}
    end
  end
end
