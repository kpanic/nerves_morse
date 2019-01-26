defmodule UiWeb.Router do
  use UiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", UiWeb do
    pipe_through :api
  end
end
