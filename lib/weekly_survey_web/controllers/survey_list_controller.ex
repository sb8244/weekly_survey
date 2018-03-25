defmodule WeeklySurveyWeb.SurveyListController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationCreationPlug

  def index(conn, _params) do
    conn
      |> assign(:surveys, WeeklySurvey.Surveys.get_available_surveys())
      |> render("index.html")
  end
end
