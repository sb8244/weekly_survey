defmodule WeeklySurvey.Users.AuthenticationCreationPlug do
  import Plug.Conn

  def init(_), do: []

  def call(conn, _) do
    {:ok, user} =
      with guid <- get_session(conn, :user_guid),
       {:ok, user} <- WeeklySurvey.Users.find_or_create_user(guid || UUID.uuid4()) do
         {:ok, user}
       else
         {:error, :user_not_found} ->
           WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
       end

    conn
      |> put_session(:user_guid, user.guid)
  end
end
