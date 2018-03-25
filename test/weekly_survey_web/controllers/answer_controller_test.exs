defmodule WeeklySurveyWeb.AnswerControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /answers" do
    test "user auth is required", %{conn: conn} do
      assert conn
        |> post(answer_path(conn, :create), answer: "testing", survey_id: 0)
        |> text_response(403) == "You must be authenticated to perform this action. Refresh and try again."
    end

    test "valid params create an answer", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> post(answer_path(conn, :create), answer: "testing", survey_id: to_string(survey.id))
        |> redirected_to(302) == "/"

      [%{answers: [answer]}] = Surveys.get_available_surveys()
      assert answer.id
      assert answer.survey_id == survey.id
      assert answer.answer == "testing"
    end
  end
end
