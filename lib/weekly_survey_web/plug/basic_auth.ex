defmodule WeeklySurveyWeb.Plug.BasicAuth do
  import Plug.Conn
  @realm "Basic realm=\"Survey Admin\""

  def init([]), do: []

  def call(conn = %{private: %{basic_auth_skip_admin: true}}, correct_auth) do
    conn
  end

  def call(conn, correct_auth) do
    case get_req_header(conn, "authorization") do
      ["Basic " <> attempted_auth] -> verify(conn, attempted_auth, correct_auth)
      _                            -> unauthorized(conn)
    end
  end

  defp valid_username_password_encodings() do
    all_credentials()
      |> String.split("||")
      |> Enum.map(fn username_password ->
        [username, password] = String.split(username_password, "::")
        encode(username, password)
      end)
  end

  defp all_credentials(), do: System.get_env("ADMIN_CREDENTIALS") || throw "no admin credentials"

  defp verify(conn, attempted_auth, []) do
    valid_username_password_encodings()
      |> Enum.any?(fn encoded_login ->
        attempted_auth == encoded_login
      end)
      |> case do
        true -> conn
        _ -> unauthorized(conn)
      end
  end

  defp encode(username, password), do: Base.encode64(username <> ":" <> password)

  defp unauthorized(conn) do
    conn
    |> put_resp_header("www-authenticate", @realm)
    |> send_resp(401, "unauthorized")
    |> halt()
  end
end
