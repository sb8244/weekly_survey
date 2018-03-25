defmodule WeeklySurvey.UsersTest do
  use WeeklySurvey.DataCase, async: true

  alias WeeklySurvey.Users
  alias WeeklySurvey.Users.UserInfo

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

  describe "set_user_info/2" do
    test "new user_info is added, if it doesn't exist" do
      {:ok, user} = Users.find_or_create_user(UUID.uuid4())
      {:ok, info = %UserInfo{}} = Users.set_user_info(user, %{name: "Steve"})
      assert info.name == "Steve"
      assert info.id
    end

    test "existing user_info is updated, if it exists" do
      {:ok, user} = Users.find_or_create_user(UUID.uuid4())
      {:ok, info = %UserInfo{}} = Users.set_user_info(user, %{name: "Steve"})
      {:ok, info2 = %UserInfo{}} = Users.set_user_info(user, %{name: "Updated"})
      assert info2.name == "Updated"
      assert info.id == info2.id
    end
  end

  describe "get_user_info/1" do
    test "no user_info is {:ok, %{}}" do
      {:ok, user} = Users.find_or_create_user(UUID.uuid4())
      {:ok, %{}} = Users.get_user_info(user)
    end

    test "user_info is {:ok, %UserInfo{}}" do
      {:ok, user} = Users.find_or_create_user(UUID.uuid4())
      {:ok, info = %UserInfo{}} = Users.set_user_info(user, %{name: "Steve"})
      {:ok, fetch_info = %UserInfo{}} = Users.get_user_info(user)

      assert info == fetch_info
    end
  end
end
