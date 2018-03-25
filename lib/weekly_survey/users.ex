defmodule WeeklySurvey.Users do
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Users.User
  alias WeeklySurvey.Users.EncryptedGuid

  def find_or_create_user(guid) do
    with {:ok, guid} <- Ecto.UUID.cast(guid) do
      find_or_create_user_from_valid_guid(guid)
    else
      :error -> {:error, :user_not_found}
    end
  end

  defp find_or_create_user_from_valid_guid(guid) do
    case Repo.get_by(User, guid: guid) do
      nil ->
        User.changeset(%User{}, %{guid: guid})
          |> Repo.insert
      user -> {:ok, user}
    end
  end

  def get_encrypted_user_payload(user: user) do
    EncryptedGuid.get_payload(user: user)
  end

  def get_user_from_encrypted_payload(token) when is_bitstring(token) do
    {:ok, %{"guid" => guid}} = EncryptedGuid.get_user_information(token)
    find_or_create_user(guid)
  end
end
