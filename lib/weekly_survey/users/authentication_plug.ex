defmodule WeeklySurvey.Users.AuthenticationPlug do
  import Plug.Conn

  def init(_), do: []

  def call(conn, _) do
    with guid when is_bitstring(guid) <- get_session(conn, :user_guid),
         {:ok, user} <- WeeklySurvey.Users.find_or_create_user(guid) do
      assign(conn, :user, user)
    else
      _ ->
      conn
        |> put_resp_header("content-type", "text/plain")
        |> send_resp(403, "You must be authenticated to perform this action. Refresh and try again.")
        |> halt()
    end
  end
end
