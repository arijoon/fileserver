defmodule ServerWeb.Router do
  use ServerWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", ServerWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  scope "/api", ServerWeb do
    pipe_through :api

    get "/items/search/:hash", ItemController, :search
    get "/items/path-search/:query", ItemController, :path_search
    post "/items/delete", ItemController, :delete
    post "/items", ItemController, :create
    post "/items/stats", ItemController, :stats
    post "/items/hash_dir", ItemController, :hash_dir
  end
end
