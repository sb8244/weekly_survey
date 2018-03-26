defmodule WeeklySurveyWeb.SessionsControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  test "it returns a json payload with a user guid token", %{conn: conn} do
    %{"ug" => token, "retrieval_method" => "new"} =
      assert conn
        |> post("/asession")
        |> json_response(200)

    {:ok, user} = WeeklySurvey.Users.get_user_from_encrypted_payload(token)
    assert user.id
  end

  test "user_info is returned", %{session_conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    WeeklySurvey.Users.set_user_info(user, %{name: "Test"})

    json =
      conn
        |> put_session(:user_guid, user.guid)
        |> post("/asession")
        |> json_response(200)

    %{"retrieval_method" => "cookie"} = json
    assert json |> Map.get("user_info") |> Map.keys() == ["name", "updated_at"]
    assert json |> Map.get("user_info") |> Map.get("name") == "Test"
  end

  test "a user GUID is assigned to cookie", %{conn: conn} do
    guid = assert conn
      |> post("/asession")
      |> get_session(:user_guid)

    assert guid =~ WeeklySurvey.TestHelpers.guid_regexp()
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(guid)
    assert user.id
  end

  test "User info in a JWT is assigned to cookie", %{conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    {:ok, payload} = WeeklySurvey.Users.get_encrypted_user_payload(user: user)

    response =
      conn
        |> post("/asession", %{"ug" => payload})

    guid = response |> get_session(:user_guid)
    %{"retrieval_method" => "jwt"} = json_response(response, 200)
    assert guid == user.guid
  end

  test "an existing user is used", %{session_conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

    assert conn
      |> put_session(:user_guid, user.guid)
      |> post("/asession")
      |> get_session(:user_guid) == user.guid
  end

  test "an invalid user is created fresh", %{session_conn: conn} do
    response =
      conn
        |> put_session(:user_guid, "fake")
        |> post("/asession")

    %{"retrieval_method" => "new"} = json_response(response, 200)
    assert get_session(response, :user_guid) =~ WeeklySurvey.TestHelpers.guid_regexp()
  end

  test "invalid user info creates a new user", %{conn: conn} do
    response =
      conn
        |> post("/asession", %{"ug" => "nope"})

    %{"retrieval_method" => "new"} = json_response(response, 200)
    guid = get_session(response, :user_guid)
    assert guid =~ WeeklySurvey.TestHelpers.guid_regexp()
  end
end
