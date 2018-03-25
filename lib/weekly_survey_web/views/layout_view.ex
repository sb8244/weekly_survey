defmodule WeeklySurveyWeb.LayoutView do
  use WeeklySurveyWeb, :view

  def get_csrf_token() do
    Plug.CSRFProtection.get_csrf_token()
  end
end
