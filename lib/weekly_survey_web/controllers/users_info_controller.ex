defmodule WeeklySurveyWeb.UsersInfoController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Users

  def update(conn = %{assigns: %{user: user}}, params) do
    {:ok, _} = Users.set_user_info(user, update_params(params))

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp update_params(%{"name" => name}) do
    %{
      name: name
    }
  end
end
