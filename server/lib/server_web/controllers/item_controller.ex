defmodule ServerWeb.ItemController do
  use ServerWeb, :controller

  alias Server.Items
  alias ServerWeb.ItemView
  alias Server.Items.Item
  alias FileServer.Operations

  action_fallback ServerWeb.FallbackController

  def create(conn, %{"path" => path, "filename" => filename, "folder" => folder}) do
    with {:ok, %Item{} = item} <- Operations.new_file(path, filename, folder) do
      conn
      |> put_status(:created)
      |> render("show.json", item: item)
    end
  end

  def create(conn, %{"items" => items}) when is_list(items) do
    result =
      items
      |> Enum.map(fn %{"path" => path, "filename" => filename, "folder" => folder} ->
        with {:ok, %Item{} = item} <- Operations.new_file(path, filename, folder) do
          item
        else
          _ -> nil
        end
      end)
      |> Enum.reject(&is_nil/1)

    conn
    |> put_status(:created)
    |> render("index.json", items: result)
  end

  def search(conn, %{"hash" => hash}) do
    items = Items.get_by_hash(hash)
    render(conn, "index.json", items: items)
  end

  def path_search(conn, %{"query" => query}) do
    items = Items.path_search(query)
    render(conn, "paths.json", items: items)
  end

  def path_search_v2(conn, %{"query" => query}) do
    items = Items.path_search_v2(query)
    render(conn, "paths.json", items: items)
  end

  def rand_search(conn, %{"query" => query, "mints" => mints, "maxts" => maxts}) do
    items =
      query
      |> str_to_lst()
      |> Items.rand_from(mints, maxts)

    render(conn, "index.json", items: items)
  end

  def fuzzy_search(conn, %{"query" => query}) do
    items = Items.fuzzy_search(query)
    render(conn, "paths.json", items: items)
  end

  def delete(conn, %{"hash" => hash, "user" => username}) do
    count = Items.delete_by(:hash, hash, username)
    render(conn, "delete.json", count: count)
  end

  def stats(conn, %{"path" => path}) do
    paths = str_to_lst(path)
    user_contrib = Items.user_contrib(paths)
    count = Items.count_items(paths)

    conn
    |> put_view(ItemView)
    |> render("stats.json", count: count, user_contrib: user_contrib)
  end

  def hash_dir(conn, %{"path" => path}) do
    Task.start(fn ->
      sanitize_path(path)
      |> Operations.reset_dir()
    end)

    send_resp(conn, :no_content, "")
  end

  defp str_to_lst(str) do
    String.split(str, ",", trim: true)
  end

  defp sanitize_path(path) do
    String.replace(path, "..", ".")
  end
end
