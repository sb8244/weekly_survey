defmodule WeeklySurveyWeb.SurveyListControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  test "HTML is rendered", %{conn: conn} do
    html =
      conn
        |> get("/")
        |> html_response(200)

    assert html =~ "<h2>Available Surveys</h2>"
  end
end
