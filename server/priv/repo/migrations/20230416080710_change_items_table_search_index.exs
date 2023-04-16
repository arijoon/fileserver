defmodule Server.Repo.Migrations.ChangeItemsTableSearchIndex do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS pg_trgm;"
    execute "CREATE INDEX items_path_gin ON items USING gin (path gin_trgm_ops);"
    execute "ALTER TABLE items ADD COLUMN path_vec tsvector GENERATED ALWAYS AS (to_tsvector('english', translate(path, '/.', ' '))) STORED;"
    execute "CREATE INDEX items_path_vec ON items USING gin (path_vec);"
  end

  def rollback do
    execute "DROP INDEX items_path_gin"
    execute "DROP INDEX items_path_vec"
    execute "ALTER TABLE items DROP COLUMN path_vec;"
  end
end
