defmodule WeeklySurveyWeb.DiscussionControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /discussions" do
    test "valid params create an discussion", %{conn: conn} do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"})

      assert conn
        |> post(discussion_path(conn, :create), content: "testing", answer_id: to_string(answer.id))
        |> redirected_to(302) == "/"

      [%{answers: [%{discussions: [discussion]}]}] = Surveys.get_available_surveys()
      assert discussion.id
      assert discussion.answer_id == answer.id
      assert discussion.content == "testing"
    end
  end
end
