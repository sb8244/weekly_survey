defmodule WeeklySurveyWeb.UsersInfoController do
  use WeeklySurveyWeb, :controller

  plug WeeklySurvey.Users.AuthenticationPlug

  alias WeeklySurvey.Users

  def update(conn = %{assigns: %{user: user}}, params) do
    conn =
      case Users.set_user_info(user, update_params(params)) do
        {:ok, _} -> conn
        {:error, changeset = %Ecto.Changeset{}} ->
          message = "Your change failed: " <> get_message_from_errors(changeset.errors)
          put_flash(conn, :error, message)
      end

    conn
      |> redirect(to: survey_list_path(conn, :index))
  end

  defp update_params(%{"name" => name}) do
    %{
      name: name
    }
  end

  defp get_message_from_errors(errors) do
    errors
    |> Enum.map(fn {key, {message, _}} ->
        Enum.join([to_string(key), to_string(message)], " ")
      end)
    |> Enum.join(", ")
  end
end
