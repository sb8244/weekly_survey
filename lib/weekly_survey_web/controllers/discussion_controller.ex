defmodule WeeklySurveyWeb.DiscussionController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn, params) do
    handle_ecto_operation(&add_discussion_to_answer/1, [conn: conn, params: params], error_reason: "Your discussion was not added")
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp creation_params(%{"content" => content}) do
    %{
      content: content
    }
  end

  defp add_discussion_to_answer(conn: %{assigns: %{user: user}}, params: params = %{"answer_id" => answer_id}) do
    Surveys.add_discussion_to_answer(String.to_integer(answer_id), creation_params(params), user: user)
      |> case do
        {:error, :no_info} -> {:error, fake_ecto_error("please", "enter your name")}
        result -> result
      end
  end
end
