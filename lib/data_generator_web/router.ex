defmodule DataGeneratorWeb.Router do
  use DataGeneratorWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", DataGeneratorWeb do
    pipe_through :api

    get "/generate", DataController, :generate
  end
end
