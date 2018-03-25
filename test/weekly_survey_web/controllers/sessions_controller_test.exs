defmodule WeeklySurveyWeb.SessionsControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  test "it's an empty json payload", %{conn: conn} do
    %{"ug" => token} =
      assert conn
        |> post("/asession")
        |> json_response(200)

    {:ok, user} = WeeklySurvey.Users.get_user_from_encrypted_payload(token)
    assert user.id
  end

  test "a user GUID is assigned to cookie", %{conn: conn} do
    guid = assert conn
      |> post("/asession")
      |> get_session(:user_guid)

    assert guid =~ WeeklySurvey.TestHelpers.guid_regexp()
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(guid)
    assert user.id
  end

  test "an existing user is used", %{session_conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

    assert conn
      |> put_session(:user_guid, user.guid)
      |> post("/asession")
      |> get_session(:user_guid) == user.guid
  end

  test "an invalid user is created fresh", %{session_conn: conn} do
    assert conn
      |> put_session(:user_guid, "fake")
      |> post("/asession")
      |> get_session(:user_guid) =~ WeeklySurvey.TestHelpers.guid_regexp()
  end
end
