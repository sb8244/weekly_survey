defmodule WeeklySurveyWeb.AnswerController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn= %{assigns: %{user: user}}, params = %{"survey_id" => survey_id}) do
    {:ok, _} = Surveys.add_answer_to_survey(String.to_integer(survey_id), creation_params(params), user: user)

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"answer" => answer}) do
    %{
      answer: answer
    }
  end
end
