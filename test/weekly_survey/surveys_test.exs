defmodule WeeklySurvey.SurveysTest do
  use WeeklySurvey.DataCase, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  def valid_survey_params(params = %{}) do
    @valid_survey_params
      |> Map.merge(params)
  end

  describe "get_available_surveys/1" do
    test "active surveys are returned" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = Surveys.create_survey(Map.merge(@valid_survey_params, %{active_until: Utils.Time.seconds_from_now(1)}))

      surveys = Surveys.get_available_surveys(user: user)
      assert length(surveys) == 1
    end

    test "inactive surveys are not returned" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = Surveys.create_survey(Map.merge(@valid_survey_params, %{active_until: Utils.Time.seconds_from_now(0)}))

      surveys = Surveys.get_available_surveys(user: user)
      assert length(surveys) == 0
    end

    test "all surveys are returned with answers and discussion (temporary, need to scope to active only)" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, survey2} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer1} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion1} = Surveys.add_discussion_to_answer(answer1.id, %{content: "Discuss"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)

      surveys = Surveys.get_available_surveys(user: user)
      assert length(surveys) == 2

      assert Enum.at(surveys, 0).id == survey2.id
      assert Enum.at(surveys, 1).id == survey.id
      assert Enum.at(surveys, 1).answers |> Enum.map(& &1.id) == [answer1.id, answer2.id]
      assert Enum.at(surveys, 0).answers == []

      discussion1 = discussion1 |> Repo.preload(:votes) |> Repo.preload(user: [:user_info])
      assert surveys |> Enum.at(1) |> Map.get(:answers) |> Enum.at(0) |> Map.get(:discussions) == [discussion1]
    end

    test "votes by the current user for answers only are returned" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, _} = Surveys.cast_vote(answer, user: user)
      {:ok, _} = Surveys.cast_vote(answer, user: user2)

      surveys = Surveys.get_available_surveys(user: user)
      answers = surveys |> Enum.at(0) |> Map.get(:answers)
      assert length(answers) == 1

      votes = answers |> Enum.at(0) |> Map.get(:votes)
      assert length(votes) == 1
      assert votes |> Enum.at(0) |> Map.get(:user_id) == user.id
    end

    test "votes by all users for discussions are returned" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      {:ok, _} = Surveys.cast_vote(discussion, user: user)
      {:ok, _} = Surveys.cast_vote(discussion, user: user2)

      surveys = Surveys.get_available_surveys(user: user)
      answers = surveys |> Enum.at(0) |> Map.get(:answers)
      assert length(answers) == 1

      votes = answers |> Enum.at(0) |> Map.get(:discussions) |> Enum.at(0) |> Map.get(:votes)
      assert length(votes) == 2
    end

    test "no votes are returned for answers, without a user" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, _} = Surveys.cast_vote(answer, user: user)
      {:ok, _} = Surveys.cast_vote(answer, user: user2)

      surveys = Surveys.get_available_surveys(user: nil)
      answers = surveys |> Enum.at(0) |> Map.get(:answers)
      assert length(answers) == 1

      votes = answers |> Enum.at(0) |> Map.get(:votes)
      assert length(votes) == 0
    end
  end

  describe "admin_get_survey_list/0" do
    test "all recent surveys are included, with votes (plus user information), sorted by vote_count" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user_info} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user3} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

      {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
      {:ok, survey2} = Surveys.create_survey(valid_survey_params(%{question: "Two"}))
      {:ok, expired_survey} = Surveys.create_survey(valid_survey_params(%{active_until: Utils.Time.seconds_from_now(-1), question: "Three"}))
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "One"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey, %{answer: "Two"}, user: user)
      {:ok, answer3} = Surveys.add_answer_to_survey(survey, %{answer: "Three"}, user: user)
      {:ok, _} = Surveys.cast_vote(answer3, user: user)
      {:ok, _} = Surveys.cast_vote(answer3, user: user2)
      {:ok, _} = Surveys.cast_vote(answer2, user: user3)

      surveys = Surveys.admin_get_survey_list()
      assert length(surveys) == 3
      # Newest should be first
      assert Enum.map(surveys, & &1.id) == [expired_survey.id, survey2.id, survey.id]

      retrieved_survey = Enum.at(surveys, 2)
      assert Enum.map(retrieved_survey.answers, & &1.id) == [answer3.id, answer2.id, answer.id]
      assert Enum.map(retrieved_survey.answers, & &1.vote_count) == [2, 1, 0]
      first_vote = retrieved_survey.answers |> List.first() |> Map.get(:votes) |> List.first()
      assert first_vote |> Map.get(:user) |> Map.get(:user_info) == user_info
    end

    test "surveys that ended > 90 days ago are not displayed" do
      {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
      {:ok, survey2} = Surveys.create_survey(valid_survey_params(%{active_until: Utils.Time.days_from_now(-89), question: "Two"}))
      {:ok, _expired_survey} = Surveys.create_survey(valid_survey_params(%{active_until: Utils.Time.days_from_now(-90), question: "Three"}))

      surveys = Surveys.admin_get_survey_list()
      assert length(surveys) == 2
      assert Enum.map(surveys, & &1.id) == [survey2.id, survey.id]
    end
  end

  describe "create_survey/1" do
    test "a valid survey is created" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      assert survey.id
      assert survey.name == "Test"
      assert survey.question == "A question?"
      assert NaiveDateTime.diff(survey.active_until, Utils.Time.days_from_now(7), :seconds) == 0
    end

    test "invalid surveys give an error changeset" do
      {:error, changeset} = Surveys.create_survey(%{name: "", question: ""})
      assert changeset.errors |> Keyword.keys == [:question]
    end
  end

  describe "add_answer_to_survey/2" do
    test "a valid answer is added to a survey" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      assert answer.id
      assert answer.survey_id == survey.id
      assert answer.answer == "Answer"
    end

    test "a survey_id can be used" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      assert answer.id
      assert answer.survey_id == survey.id
    end

    test "an invalid survey_id is an error" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:error, changeset} = Surveys.add_answer_to_survey(survey.id + 1, %{answer: "Answer"}, user: user)
      assert changeset.errors |> Keyword.keys == [:survey_id]
    end
  end

  describe "add_discussion_to_answer/2" do
    test "user info is required to add a discussion" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      {:error, :no_info} = Surveys.add_discussion_to_answer(answer, %{content: "Discuss"}, user: user)
    end

    test "a valid discussion is added to an answer" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer, %{content: "Discuss"}, user: user)
      assert discussion.id
      assert discussion.answer_id == answer.id
      assert discussion.content == "Discuss"
    end

    test "a valid discussion is added to an answer by id" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      assert discussion.id
      assert discussion.answer_id == answer.id
    end
  end

  describe "get_voteable/3" do
    test "an answer is found" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, ^answer} = Surveys.get_voteable("answer", answer.id)
    end

    test "a discussion is found" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      {:ok, ^discussion} = Surveys.get_voteable("discussion", discussion.id)
    end

    test "an invalid type is an error" do
      {:error, :invalid_type} = Surveys.get_voteable("nope", 0)
    end

    test "an invalid id is an error" do
      {:error, :not_found} = Surveys.get_voteable("discussion", 0)
    end
  end

  describe "cast_vote/2" do
    test "a user can cast a vote for an answer" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)

      assert vote.user_id == user.id
      assert vote.id
      assert vote.voteable_id == answer.id
    end

    test "2 users can cast a votes for different answers on the same survey" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)
      {:ok, vote2} = Surveys.cast_vote(answer2, user: user2)

      assert vote.user_id == user.id
      assert vote2.user_id == user2.id
    end

    test "a user can not cast a vote for an answer when another survey answer is voted on" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, _} = Surveys.cast_vote(answer, user: user)
      {:error, :duplicate_vote} = Surveys.cast_vote(answer2, user: user)
    end

    test "a user can cast a vote for a discussion" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      {:ok, vote} = Surveys.cast_vote(discussion, user: user)

      assert vote.user_id == user.id
      assert vote.id
      assert vote.voteable_id == discussion.id
    end

    test "a user cannot double vote for an item" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)
      {:ok, vote2} = Surveys.cast_vote(answer, user: user)

      assert vote.id
      assert vote2.id == nil
    end
  end

  describe "remove_vote/3" do
    test "a valid answer vote can be removed" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)
      :ok = Surveys.remove_vote("answer", vote.id, user: user)
    end

    test "another user's vote can't be removed" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, vote} = Surveys.cast_vote(answer, user: user)
      {:error, :not_found} = Surveys.remove_vote("answer", vote.id, user: user2)
    end

    test "a discussion vote can be removed" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, _} = WeeklySurvey.Users.set_user_info(user, %{name: "Test"})
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      {:ok, vote} = Surveys.cast_vote(discussion, user: user)
      :ok = Surveys.remove_vote("discussion", vote.id, user: user)
    end


    test "an unknown voteable type can't be removed" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

      assert_raise(FunctionClauseError, fn ->
        Surveys.remove_vote("nope", 0, user: user)
      end)
    end
  end
end
