defmodule WeeklySurveyWeb.UsersInfoControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  describe "PUT /user_infos" do
    test "the UserInfo for the associated user is updated with included fields", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

      assert conn
        |> put_session(:user_guid, user.guid)
        |> put(users_info_path(conn, :update), %{name: "Steve"})
        |> redirected_to(302) == "/"

      {:ok, %{name: "Steve"}} = WeeklySurvey.Users.get_user_info(user)
    end
  end
end
