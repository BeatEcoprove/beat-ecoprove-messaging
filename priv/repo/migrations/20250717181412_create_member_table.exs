defmodule Messaging.Repo.Migrations.CreateMemberTable do
use Ecto.Migration

  def change do
    create table(:members, primary_key: false) do
      add :id, :string
      add :user_id, references(:users, type: :string, on_delete: :delete_all), null: false
      add :group_id, references(:groups, type: :string, on_delete: :delete_all), null: false

      timestamps()
      add :deleted_at, :utc_datetime_usec, default: nil
    end

    create unique_index(:members, [:user_id, :group_id], name: :members_user_group_unique_index)
    create index(:members, [:deleted_at])
  end
end
