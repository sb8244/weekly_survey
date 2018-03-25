defmodule WeeklySurveyWeb.LayoutView do
  use WeeklySurveyWeb, :view

  def get_csrf_token() do
    Plug.CSRFProtection.get_csrf_token()
  end

  def has_flash_messages(conn) do
    Phoenix.Controller.get_flash(conn)
      |> Map.keys()
      |> Enum.any?()
  end
end
