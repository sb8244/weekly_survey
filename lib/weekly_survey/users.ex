defmodule WeeklySurvey.Users do
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Users.User
  alias WeeklySurvey.Users.UserInfo
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
    case EncryptedGuid.get_user_information(token) do
      {:ok, %{"guid" => guid}} -> find_or_create_user(guid)
      _ -> {:error, :invalid_jwt}
    end
  end

  def set_user_info(%User{id: id}, params) do
    UserInfo.changeset(%UserInfo{}, Map.merge(params, %{user_id: id}))
      |> Repo.insert(on_conflict: :replace_all, conflict_target: :user_id)
  end

  def get_user_info(%User{id: id}) do
    case Repo.get_by(UserInfo, user_id: id) do
      nil -> {:ok, %{}}
      info = %UserInfo{} -> {:ok, info}
    end
  end
end
