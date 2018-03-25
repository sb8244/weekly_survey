defmodule WeeklySurveyWeb.AnswerControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /answers" do
    test "user auth is required", %{conn: conn} do
      assert conn
        |> post(answer_path(conn, :create), answer: "testing", survey_id: 0)
        |> text_response(403) =~ "You must be authenticated"
    end

    test "valid params create an answer", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> post(answer_path(conn, :create), answer: "testing", survey_id: to_string(survey.id))
        |> redirected_to(302) == "/"

      [%{answers: [answer]}] = Surveys.get_available_surveys(user: nil)
      assert answer.id
      assert answer.survey_id == survey.id
      assert answer.answer == "testing"
    end

    test "invalid params render a flash error", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

      response = conn
        |> put_session(:user_guid, user.guid)
        |> post(answer_path(conn, :create), answer: " ", survey_id: "0")

      assert redirected_to(response, 302) == "/"
      assert get_flash(response, :error) == "Your answer was not added: answer can't be blank"
    end

    test "invalid relationship render a flash error", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

      response = conn
        |> put_session(:user_guid, user.guid)
        |> post(answer_path(conn, :create), answer: "x", survey_id: "0")

      assert redirected_to(response, 302) == "/"
      assert get_flash(response, :error) =~ "survey_id does not exist"
    end
  end
end
