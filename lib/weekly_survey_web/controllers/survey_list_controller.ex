defmodule WeeklySurveyWeb.SurveyListController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug, [required: false]

  def index(conn = %{assigns: assigns}, _params) do
    user = Map.get(assigns, :user)

    conn
      |> assign(:surveys, get_surveys(user))
      |> render("index.html")
  end

  defp get_surveys(user) do
    WeeklySurvey.Surveys.get_available_surveys(user: user)
      |> Enum.map(fn survey ->
        has_vote = survey.has_answer_vote || survey_has_answer_vote?(survey)
        Map.put(survey, :has_answer_vote, has_vote)
      end)
  end

  defp survey_has_answer_vote?(survey) do
    Enum.any?(survey.answers, fn %{votes: votes} ->
      length(votes) > 0
    end)
  end
end
