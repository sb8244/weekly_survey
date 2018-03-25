defmodule WeeklySurvey.UsersTest do
  use WeeklySurvey.DataCase, async: true

  alias WeeklySurvey.Users

  describe "find_or_create_user/1" do
    test "a new user is created when the guid doesn't exist" do
      guid = UUID.uuid4()
      {:ok, user} = Users.find_or_create_user(guid)
      assert user.id
      assert user.guid == guid
    end

    test "an existing user is found by UUID" do
      guid = UUID.uuid4()
      {:ok, user1} = Users.find_or_create_user(guid)
      {:ok, user2} = Users.find_or_create_user(guid)

      assert user1 == user2
    end

    test "an invalid GUID is a failure" do
      {:error, :user_not_found} = Users.find_or_create_user("X")
    end
  end
end
