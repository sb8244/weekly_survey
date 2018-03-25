defmodule WeeklySurveyWeb.EctoOperationHelper do
  def handle_ecto_operation(operation, args) when is_list(args) do
    handle_ecto_operation(operation, args, [])
  end

  def handle_ecto_operation(operation, args, kwargs) when is_list(args) do
    conn = Keyword.fetch!(args, :conn)
    error_reason = Keyword.get(kwargs, :error_reason, "Your change failed")

    case operation.(args) do
      {:ok, _} -> conn
      {:error, changeset = %Ecto.Changeset{}} ->
        message = error_reason <> ": " <> get_message_from_errors(changeset.errors)
        Phoenix.Controller.put_flash(conn, :error, message)
    end
  end

  def get_message_from_errors(errors) do
    errors
    |> Enum.map(fn {key, {message, _}} ->
        Enum.join([to_string(key), to_string(message)], " ")
      end)
    |> Enum.join(", ")
  end
end
