defmodule ServerWeb.ItemView do
  use ServerWeb, :view
  alias ServerWeb.ItemView

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
end
