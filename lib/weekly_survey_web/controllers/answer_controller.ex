defmodule WeeklySurveyWeb.AnswerController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn, params) do
    handle_ecto_operation(&add_answer_to_survey/1, [conn: conn, params: params], error_reason: "Your answer was not added")
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"answer" => answer}) do
    %{
      answer: answer
    }
  end

  defp add_answer_to_survey(conn: %{assigns: %{user: user}}, params: params = %{"survey_id" => survey_id}) do
    Surveys.add_answer_to_survey(String.to_integer(survey_id), creation_params(params), user: user)
  end
end
