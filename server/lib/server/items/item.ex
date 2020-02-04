defmodule Server.Items.Item do
  use Ecto.Schema
  import Ecto.Changeset

  schema "items" do
    field :added, :utc_datetime
    field :filename, :string
    field :user, :string
    field :path, :string

    timestamps()
  end

  @doc false
  def changeset(item, attrs) do
    item
    |> cast(attrs, [:path, :filename, :user, :added])
    |> validate_required([:path, :filename, :user, :added])
  end
end
