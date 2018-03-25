defmodule WeeklySurveyWeb.SessionsController do
  use WeeklySurveyWeb, :controller

  def create_anonymous(conn, _params) do
    {:ok, user} = get_user(conn)
    {:ok, encrypted_user_info} = WeeklySurvey.Users.get_encrypted_user_payload(user: user)

    conn
      |> put_session(:user_guid, user.guid)
      |> json(%{ug: encrypted_user_info})
  end

  defp get_user(conn) do
    with guid <- get_session(conn, :user_guid),
     {:ok, user} <- WeeklySurvey.Users.find_or_create_user(guid || UUID.uuid4()) do
       {:ok, user}
     else
       {:error, :user_not_found} ->
         WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
     end
  end
end
