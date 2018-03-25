defmodule WeeklySurveyWeb.SurveyListController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug, [required: false]

  def index(conn = %{assigns: assigns}, _params) do
    user = Map.get(assigns, :user)

    conn
      |> assign(:surveys, WeeklySurvey.Surveys.get_available_surveys(user: user))
      |> render("index.html")
  end
end
