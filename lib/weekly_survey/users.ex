defmodule WeeklySurvey.Users do
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Users.User
  import Ecto.Query

  def find_or_create_user(guid) do
    with {:ok, guid} <- Ecto.UUID.cast(guid) do
      find_or_create_user_from_valid_guid(guid)
    else
      :error -> {:error, "An error occurred with the User GUID provided"}
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
end
