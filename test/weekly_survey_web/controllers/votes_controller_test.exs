defmodule WeeklySurveyWeb.VotesControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /votes" do
    test "a vote is added for an answer", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> post(votes_path(conn, :create), voteable_type: "answer", voteable_id: to_string(answer.id))
        |> redirected_to(302) == "/"

      answer = Repo.preload(answer, :votes)
      assert answer.votes |> length() == 1
    end

    test "a vote is added for a discussion", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer, %{content: "A Discuss"}, user: user)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> post(votes_path(conn, :create), voteable_type: "discussion", voteable_id: to_string(discussion.id))
        |> redirected_to(302) == "/"

      discussion = Repo.preload(discussion, :votes)
      assert discussion.votes |> length() == 1
    end
  end
end
