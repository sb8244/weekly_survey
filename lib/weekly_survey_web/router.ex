defmodule WeeklySurveyWeb.Router do
  use WeeklySurveyWeb, :router

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

  scope "/", WeeklySurveyWeb do
    pipe_through :browser # Use the default browser stack

    get "/", SurveyListController, :index
    resources "/answers", AnswerController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", WeeklySurveyWeb do
  #   pipe_through :api
  # end
end