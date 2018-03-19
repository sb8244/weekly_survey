defmodule WeeklySurveyWeb.DiscussionController do
  use WeeklySurveyWeb, :controller

  alias WeeklySurvey.Surveys

  def create(conn, params = %{"answer_id" => answer_id}) do
    {:ok, _} = Surveys.add_discussion_to_answer(String.to_integer(answer_id), creation_params(params))

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"content" => content}) do
    %{
      content: content
    }
  end
end
