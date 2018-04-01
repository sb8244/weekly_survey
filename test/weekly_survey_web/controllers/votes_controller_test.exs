defmodule WeeklySurveyWeb.VotesControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "POST /votes" do
    test "an invalid vote type is an error", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)

      response =
        conn
          |> put_session(:user_guid, user.guid)
          |> post(votes_path(conn, :create), voteable_type: "bleh", voteable_id: to_string(answer.id))

      assert get_flash(response, :error) == "Your vote was not added: bleh is invalid"
      answer = Repo.preload(answer, :votes)
      assert answer.votes |> length() == 0
    end

    test "an invalid vote id is an error", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)

      response =
        conn
          |> put_session(:user_guid, user.guid)
          |> post(votes_path(conn, :create), voteable_type: "answer", voteable_id: "0")

      assert get_flash(response, :error) == "Your vote was not added: answer was not found"
      answer = Repo.preload(answer, :votes)
      assert answer.votes |> length() == 0
    end

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

    test "an answer vote can't be cast if another answer vote is on the survey", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)

      response =
        conn
          |> put_session(:user_guid, user.guid)
          |> post(votes_path(conn, :create), voteable_type: "answer", voteable_id: to_string(answer.id))
          |> post(votes_path(conn, :create), voteable_type: "answer", voteable_id: to_string(answer2.id))

      assert get_flash(response, :error) == "Your vote was not added: answer has already been voted on"
      assert Repo.aggregate({"answers_votes", Surveys.Vote}, :count, :id) == 1
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

  describe "DELETE /votes/:id" do
    test "a valid vote can be deleted", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)

      assert conn
        |> put_session(:user_guid, user.guid)
        |> delete(votes_path(conn, :delete, vote.id), voteable_type: "answer")
        |> redirected_to(302) == "/"

      assert Repo.aggregate({"answers_votes", Surveys.Vote}, :count, :id) == 0
    end

    test "a vote by another user cannot be deleted", %{session_conn: conn} do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)

      response =
        conn
          |> put_session(:user_guid, user2.guid)
          |> delete(votes_path(conn, :delete, vote.id), voteable_type: "answer")

      assert get_flash(response, :error) == "Your vote was not removed: vote was not found"
      assert Repo.aggregate({"answers_votes", Surveys.Vote}, :count, :id) == 1
    end
  end
end
