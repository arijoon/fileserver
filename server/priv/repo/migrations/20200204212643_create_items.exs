defmodule Server.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create table(:items) do
      add :path, :string, null: false
      add :filename, :string, null: false
      add :user, :string, null: false
      add :added, :utc_datetime, null: false

      timestamps()
    end

    create index(:items, [:path])
    create index(:items, [:filename])
    create index(:items, [:user])
    create index(:items, [:path, :filename], unique: true)
  end
end
