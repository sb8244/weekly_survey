defmodule WeeklySurveyWeb.SessionsController do
  use WeeklySurveyWeb, :controller

  alias WeeklySurvey.Users

  def create_anonymous(conn, params) do
    {{:ok, user}, retrieval_method} = get_user(conn, params)
    {:ok, encrypted_user_info} = Users.get_encrypted_user_payload(user: user)

    conn
      |> put_session(:user_guid, user.guid)
      |> json(%{ug: encrypted_user_info, user_info: get_user_info(user), retrieval_method: retrieval_method})
  end

  defp get_user(conn, params) do
    user =
      case get_session(conn, :user_guid) do
        nil ->
          case Map.get(params, "ug") do
            nil -> {create_new_user(), :new}
            jwt -> {Users.get_user_from_encrypted_payload(jwt), :jwt}
          end
        guid -> {Users.find_or_create_user(guid), :cookie}
      end

    case user do
      {{:error, :invalid_jwt}, _} -> {create_new_user(), :new}
      {{:error, :user_not_found}, _} -> {create_new_user(), :new}
      success -> success
    end
  end

  defp create_new_user() do
    Users.find_or_create_user(UUID.uuid4())
  end

  defp get_user_info(user) do
    {:ok, info} = Users.get_user_info(user)
    Map.take(info, [:name, :updated_at])
  end
end
