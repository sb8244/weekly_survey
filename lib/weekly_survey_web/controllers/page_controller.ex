defmodule WeeklySurveyWeb.PageController do
  use WeeklySurveyWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
