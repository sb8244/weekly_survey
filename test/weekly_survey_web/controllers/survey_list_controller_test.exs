defmodule WeeklySurveyWeb.SurveyListControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  test "HTML is rendered", %{conn: conn} do
    html =
      conn
        |> get("/")
        |> html_response(200)

    assert html =~ "<h2>Available Surveys</h2>"
  end

  test "a user GUID is assigned to cookie", %{conn: conn} do
    assert conn
      |> get("/")
      |> get_session(:user_guid) =~ WeeklySurvey.TestHelpers.guid_regexp()
  end

  test "an existing user is used", %{session_conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

    assert conn
      |> put_session(:user_guid, user.guid)
      |> get("/")
      |> get_session(:user_guid) == user.guid
  end

  test "an invalid user is created fresh", %{session_conn: conn} do
    assert conn
      |> put_session(:user_guid, "fake")
      |> get("/")
      |> get_session(:user_guid) =~ WeeklySurvey.TestHelpers.guid_regexp()
  end
end
