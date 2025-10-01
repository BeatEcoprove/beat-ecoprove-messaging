defmodule Messaging.Repo.Migrations.CreateInviteTable do
  use Ecto.Migration

  def change do
    create table(:invites, primary_key: false) do
      add(:id, :string, primary_key: true)

      add(:group_id, references(:groups, type: :string, on_delete: :delete_all), null: false)
      add(:inviter_id, references(:users, type: :string, on_delete: :delete_all), null: false)
      add(:invitee_id, references(:users, type: :string, on_delete: :delete_all), null: false)

      add(:public_id, :string)
      add(:token, :string, null: false)
      add(:status, :integer, default: 0)
      add(:role, :integer, default: 0)

      timestamps()
      add(:deleted_at, :utc_datetime_usec, default: nil)
    end

    create(index(:invites, [:deleted_at]))
  end
end
