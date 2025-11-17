defmodule Messaging.Repo.Migrations.CreateUserTable do
  use Ecto.Migration

  def change do
    create table(:users, primary_key: false) do
      add(:id, :string, primary_key: true)
      add(:auth_id, :string)
      add(:profile_id, :string)
      add(:display_name, :string, null: false)
      add(:role, :string, null: false)

      timestamps()
      add(:deleted_at, :utc_datetime_usec)
    end

    create(index(:users, [:deleted_at]))
  end
end
