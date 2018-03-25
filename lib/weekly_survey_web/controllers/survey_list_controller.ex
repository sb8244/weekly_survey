defmodule WeeklySurveyWeb.SurveyListController do
  use WeeklySurveyWeb, :controller

  def index(conn, _params) do
    {:ok, user} =
      with guid <- get_session(conn, :user_guid),
       {:ok, user} <- WeeklySurvey.Users.find_or_create_user(guid || UUID.uuid4()) do
         {:ok, user}
       else
         {:error, :user_not_found} ->
           WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
       end

    conn
      |> put_session(:user_guid, user.guid)
      |> assign(:surveys, WeeklySurvey.Surveys.get_available_surveys())
      |> render("index.html")
  end
end
