defmodule WeeklySurveyWeb.AnswerControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /answers" do
    test "valid params create an answer", %{conn: conn} do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)

      assert conn
        |> post(answer_path(conn, :create), answer: "testing", survey_id: to_string(survey.id))
        |> redirected_to(302) == "/"

      [%{answers: [answer]}] = Surveys.get_available_surveys()
      assert answer.id
      assert answer.survey_id == survey.id
      assert answer.answer == "testing"
    end
  end
end
