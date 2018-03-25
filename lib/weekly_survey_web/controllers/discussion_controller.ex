defmodule WeeklySurveyWeb.DiscussionController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn = %{assigns: %{user: user}}, params = %{"answer_id" => answer_id}) do
    {:ok, _} = Surveys.add_discussion_to_answer(String.to_integer(answer_id), creation_params(params), user: user)

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"content" => content}) do
    %{
      content: content
    }
  end
end
