defmodule WeeklySurveyWeb.SessionsController do
  use WeeklySurveyWeb, :controller

  def create_anonymous(conn, params) do
    {:ok, user} = get_user(conn, params)
    {:ok, encrypted_user_info} = WeeklySurvey.Users.get_encrypted_user_payload(user: user)

    conn
      |> put_session(:user_guid, user.guid)
      |> json(%{ug: encrypted_user_info})
  end

  defp get_user(conn, params) do
    user =
      case get_session(conn, :user_guid) do
        nil ->
          case Map.get(params, "ug") do
            nil -> create_new_user()
            jwt -> WeeklySurvey.Users.get_user_from_encrypted_payload(jwt)
          end
        guid -> WeeklySurvey.Users.find_or_create_user(guid)
      end

    case user do
      {:error, :invalid_jwt} -> create_new_user()
      {:error, :user_not_found} -> create_new_user()
      success -> success
    end
  end

  defp create_new_user() do
    WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
  end
end
