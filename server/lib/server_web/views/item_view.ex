defmodule ServerWeb.ItemView do
  use ServerWeb, :view
  alias ServerWeb.ItemView

  def render("stats.json", %{count: count, user_contrib: user_contrib}) do
    %{
      data: %{
        count: count,
        user_contrib: render_many(user_contrib, ItemView, "user_contrib.json")
      }
    }
  end

  def render("index.json", %{items: items}) do
    %{data: render_many(items, ItemView, "item.json")}
  end

  def render("show.json", %{item: item}) do
    %{data: render_one(item, ItemView, "item.json")}
  end

  def render("item.json", %{item: item}) do
    %{id: item.id,
      path: item.path,
      filename: item.filename,
      user: item.user,
      added: item.added}
  end

  def render("user_contrib.json", %{item: {username, count}}) do
    %{
      username: username,
      count: count
    }
  end
end
