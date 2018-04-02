defmodule WeeklySurveyWeb.Router do
  use WeeklySurveyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :authenticated do
    plug WeeklySurveyWeb.Plug.BasicAuth
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
    resources "/votes", VotesController, only: [:create, :delete]
  end

  scope "/admin", WeeklySurveyWeb.Admin, as: :admin do
    pipe_through [:authenticated, :browser]

    get "/", SurveyListController, :index
    resources "/surveys", SurveyListController, only: [:create]
  end

  # Other scopes may use custom stacks.
  # scope "/api", WeeklySurveyWeb do
  #   pipe_through :api
  # end
end
