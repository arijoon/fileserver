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
    result = items
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

  def delete(conn, %{"hash" => hash, "user" => username}) do
    count = Items.delete_by(:hash, hash, username)
    render(conn, "delete.json", count: count)
  end

  def stats(conn, %{"path" => path}) do
    user_contrib = Items.user_contrib(path)
    count = Items.count_items(path)

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

  defp sanitize_path(path) do
    String.replace(path, "..", ".")
  end
end
