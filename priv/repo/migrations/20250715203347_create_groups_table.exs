defmodule Messaging.Repo.Migrations.CreateGroupsTable do
use Ecto.Migration

  def change do
    create table(:groups, primary_key: false) do
      add :id, :string, primary_key: true
      add :public_id, :string
      add :name, :string, null: false
      add :description, :text, null: false
      add :is_public, :boolean, null: false

      add :sustainability_points, :float, null: false
      add :xp, :float, null: false

      add :creator_id, :string
      add :avatar_img, :string

      timestamps()
      add :deleted_at, :utc_datetime_usec
    end

    create index(:groups, [:deleted_at])
  end
end
