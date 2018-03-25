defmodule WeeklySurveyWeb.DiscussionControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /discussions" do
    test "user auth is required", %{conn: conn} do
      assert conn
        |> post(discussion_path(conn, :create), content: "testing", answer_id: 0)
        |> text_response(403) =~ "You must be authenticated"
    end

    test "valid params create an discussion", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> post(discussion_path(conn, :create), content: "testing", answer_id: to_string(answer.id))
        |> redirected_to(302) == "/"

      [%{answers: [%{discussions: [discussion]}]}] = Surveys.get_available_surveys()
      assert discussion.id
      assert discussion.answer_id == answer.id
      assert discussion.content == "testing"
    end
  end
end
