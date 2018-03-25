defmodule WeeklySurvey.Users.EncryptedGuidTest do
  use ExUnit.Case, async: true

  alias WeeklySurvey.Users.EncryptedGuid

  describe "get_payload/1" do
    test "a JWT is returned and can be decrypted" do
      {:ok, payload} = EncryptedGuid.get_payload(user: %{guid: "a guid"})
      {:ok, %{"guid" => "a guid"}} = EncryptedGuid.get_user_information(payload)
    end
  end
end
