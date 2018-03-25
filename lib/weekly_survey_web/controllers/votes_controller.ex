defmodule WeeklySurveyWeb.VotesController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn, params) do
    handle_ecto_operation(&cast_vote/1, [conn: conn, params: params], error_reason: "Your vote was not added")
      |> redirect(to: survey_list_path(conn, :index))
  end

  def cast_vote(conn: %{assigns: %{user: user}}, params: %{"voteable_id" => voteable_id, "voteable_type" => voteable_type}) do
    {:ok, voteable} = Surveys.get_voteable(voteable_type, voteable_id)
    Surveys.cast_vote(voteable, user: user)
  end
end
