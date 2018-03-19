defmodule WeeklySurveyWeb.AnswerController do
  use WeeklySurveyWeb, :controller

  alias WeeklySurvey.Surveys

  def create(conn, params = %{"survey_id" => survey_id}) do
    {:ok, _} = Surveys.add_answer_to_survey(String.to_integer(survey_id), creation_params(params))

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"answer" => answer}) do
    %{
      answer: answer
    }
  end
end
