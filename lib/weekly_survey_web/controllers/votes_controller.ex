defmodule WeeklySurveyWeb.VotesController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Surveys

  def create(conn, params) do
    handle_ecto_operation(&cast_vote/1, [conn: conn, params: params], error_reason: "Your vote was not added")
      |> redirect(to: survey_list_path(conn, :index))
  end

  def cast_vote(conn: %{assigns: %{user: user}}, params: %{"voteable_id" => voteable_id, "voteable_type" => voteable_type}) do
    case Surveys.get_voteable(voteable_type, voteable_id) do
      {:ok, voteable} ->
        case Surveys.cast_vote(voteable, user: user) do
          {:error, :duplicate_vote} -> {:error, fake_ecto_error(voteable_type, "has already been voted on")}
          result -> result
        end
      {:error, :not_found} -> {:error, fake_ecto_error(voteable_type, "was not found")}
      {:error, :invalid_type} -> {:error, fake_ecto_error(voteable_type, "is invalid")}
    end
  end
end
