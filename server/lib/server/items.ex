defmodule Server.Items do
  @moduledoc """
  The Items context.
  """

  import Ecto.Query, warn: false
  alias Server.Repo

  alias Server.Items.Item

  @chunk_size 1_000
  @admin Application.get_env(:server, :admin)

  @doc """
  Gets a single item.
  """
  def get_item!(id), do: Repo.get!(Item, id)
  def get_item!(path, filename) do
    q= from i in Item,
      where: i.path == ^path and i.filename == ^filename
    Repo.one!(q)
  end

  def get_by_hash(hash) do
    hash_search(hash)
    |> Repo.all()
  end

  defp hash_search(hash), do: from i in Item, where: i.hash == ^hash

  def count_items(path) do
    q = from i in filter_path(path),
    select: { count(i.id) }
    {count} = Repo.one(q)
    count
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
     |> Enum.map(fn chunk ->
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
  """
  def update_item(%Item{} = item, attrs) do
    item
    |> Item.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a item.
  """
  def delete_item(%Item{} = item) do
    Repo.delete(item)
  end

  @doc """
  Deletes the record and file itself that match hash and user
  Admin is exception, it'll delete everything matching hash
  """
  def delete_by(:hash, hash, username) do
    query = hash_search(hash)
    query = if username == @admin do
      query
    else
      where(query, [i], i.user == ^username)
    end

    Repo.all(query)
    |> Enum.each(fn item ->
        FileServer.delete_file(item.path, item.filename)
      end)

    {count, _} = Repo.delete_all(query)
    count
  end

  def delete_all(""), do: Repo.delete_all(Item)
  def delete_all(path) do
    query = from i in filter_path(path)
    Repo.delete_all(query)
  end

  def filter_path(""), do: Item
  def filter_path(path) when is_list(path) do
    query = path
    |> Enum.reduce(false, fn filter, query ->
      str = "#{filter}/%"
      dynamic([i], like(i.path, ^str) or i.path == ^filter or ^query)
    end)
    from i in Item,
    where: ^query
  end
  def filter_path(path) do
    like_seg = "#{path}/%"
    from i in Item,
    where: like(i.path, ^like_seg) or i.path == ^path
  end

  def path_search(str) do
    str = "%/%#{str}%"
    (from i in Item,
    where: like(i.path, ^str),
    order_by: i.path,
    limit: 15,
    group_by: i.path,
    select: i.path
    )
    |> Repo.all()
  end

  def path_search_v2(str) do
    (from i in Item,
    where: fragment("path_vec @@ to_tsquery(?)", ^str),
    order_by: fragment("SIMILARITY(path, ?) DESC", ^str),
    limit: 15,
    group_by: i.path,
    select: i.path
    )
    |> Repo.all()
  end

  def fuzzy_search(str) do
    (from i in Item,
    where: fragment("SIMILARITY(path, ?) > 0.1", ^str),
    order_by: fragment("SIMILARITY(path, ?) DESC", ^str),
    group_by: i.path,
    limit: 5,
    select: i.path
    )
    |> Repo.all()
  end

  def rand_from(lst, mints, maxts) when is_list(lst) do
    {:ok, min} = DateTime.from_unix(String.to_integer(mints))
    {:ok, max} = DateTime.from_unix(String.to_integer(maxts))
    (from i in filter_path(lst),
    order_by: fragment("RANDOM()"),
    where: i.added >= ^min and i.added <= ^max,
    limit: 1,
    select: i
    )
    |> Repo.all()
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
