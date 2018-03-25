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
    post "/asession", SessionsController, :create_anonymous
    resources "/answers", AnswerController, only: [:create]
    resources "/discussions", DiscussionController, only: [:create]
    resources "/user_info", UsersInfoController, only: [:update], singleton: true
  end

  # Other scopes may use custom stacks.
  # scope "/api", WeeklySurveyWeb do
  #   pipe_through :api
  # end
end
