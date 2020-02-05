defmodule Server.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias Server.Repo

  alias Server.Items.Item

  @chunk_size 1_000

  @doc """
  Returns the list of items.

  ## Examples

      iex> list_items()
      [%Item{}, ...]

  """
  def list_items do
    Repo.all(Item)
  end

  @doc """
  Gets a single item.

  Raises `Ecto.NoResultsError` if the Item does not exist.

  ## Examples

      iex> get_item!(123)
      %Item{}

      iex> get_item!(456)
      ** (Ecto.NoResultsError)

  """
  def get_item!(id), do: Repo.get!(Item, id)
  def get_item!(path, filename) do
    q= from i in Item,
      where: i.path == ^path and i.filename == ^filename
    Repo.one!(q)
  end

  def get_by_hash(hash) do
    q = from i in Item,
      where: i.hash == ^hash
    Repo.all(q)
  end

  def user_contrib(path, limit \\ 5) do
    q = from i in filter_path(path),
    group_by: i.user,
    select: {i.user, count(i.id)},
    order_by: [desc: count(i.id)],
    limit: ^limit

    Repo.all(q)
  end

  def create_item(attrs \\ %{}) do
    %Item{}
    |> Item.changeset(attrs)
    |> Repo.insert()
  end

  def add_all(items) do
    items
     |> Stream.map(&(Item.changeset(%Item{}, &1)))
     |> Enum.chunk_every(@chunk_size)
     |> Enum.each(fn chunk ->
        items_toadd = chunk
        |> Enum.map(&Server.RepoUtils.changeset_to_map/1)
        |> Enum.map(&Server.RepoUtils.add_timestamps/1)

        Ecto.Multi.new()
        |> Ecto.Multi.insert_all(:insert_all, Item, items_toadd)
        |> Repo.transaction()
     end)
  end

  @doc """
  Updates a item.

  ## Examples

      iex> update_item(item, %{field: new_value})
      {:ok, %Item{}}

      iex> update_item(item, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.

  ## Examples

      iex> delete_item(item)
      {:ok, %Item{}}

      iex> delete_item(item)
      {:error, %Ecto.Changeset{}}

  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  def delete_all(""), do: Repo.delete_all(Item)
  def delete_all(path) do
    query = from i in filter_path(path)
    Repo.delete_all(query)
  end

  def filter_path(""), do: Item
  def filter_path(path) do
    like_seg = "#{path}/%"
    from i in Item,
    where: like(i.path, ^like_seg) or i.path == ^path
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking item changes.

  ## Examples

      iex> change_item(item)
      %Ecto.Changeset{source: %Item{}}

  """
  def change_item(%Item{} = item) do
    Item.changeset(item, %{})
  end
end
