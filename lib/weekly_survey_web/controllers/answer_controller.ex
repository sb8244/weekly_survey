defmodule WeeklySurveyWeb.AnswerController do
  use WeeklySurveyWeb, :controller

  alias WeeklySurvey.Surveys

  def create(conn, %{"answer" => answer, "survey_id" => survey_id}) do
    {:ok, _} = Surveys.add_answer_to_survey(survey_id, answer)

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end
end
