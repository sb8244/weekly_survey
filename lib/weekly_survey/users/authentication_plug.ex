defmodule WeeklySurvey.Users.AuthenticationPlug do
  import Plug.Conn

  def init(args) do
    required = Keyword.get(args, :required, true)
    [required: required]
  end

  def call(conn, [required: required]) do
    with guid when is_bitstring(guid) <- get_session(conn, :user_guid),
         {:ok, user} <- WeeklySurvey.Users.find_or_create_user(guid) do
      assign(conn, :user, user)
    else
      _ ->
        if required do
          conn
            |> put_resp_header("content-type", "text/plain")
            |> send_resp(403, "You must be authenticated to perform this action. Load the app in a different window to get a session, then refresh and try again.")
            |> halt()
        else
          conn
        end
    end
  end
end
