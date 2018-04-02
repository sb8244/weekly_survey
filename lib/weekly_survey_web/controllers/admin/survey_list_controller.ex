defmodule WeeklySurveyWeb.Admin.SurveyListController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug, [required: false]

  def index(conn = %{assigns: assigns}, _params) do
    conn
      |> assign(:surveys, get_surveys())
      |> render("index.html")
  end

  defp get_surveys() do
    WeeklySurvey.Surveys.admin_get_survey_list()
  end
end
