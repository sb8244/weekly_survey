defmodule WeeklySurvey.SurveysTest do
  use WeeklySurvey.DataCase, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  describe "create_survey/1" do
    test "a valid survey is created" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      assert survey.id
      assert survey.name == "Test"
      assert survey.question == "A question?"
    end

    test "invalid surveys give an error changeset" do
      {:error, changeset} = Surveys.create_survey(%{name: "", question: ""})
      assert changeset.errors |> Keyword.keys == [:name, :question]
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
    test "a valid discussion is added to an answer" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer, %{content: "Discuss"}, user: user)
      assert discussion.id
      assert discussion.answer_id == answer.id
      assert discussion.content == "Discuss"
    end

    test "a valid discussion is added to an answer by id" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"}, user: user)
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"}, user: user)
      assert discussion.id
      assert discussion.answer_id == answer.id
    end
  end

  describe "get_available_surveys/0" do
    test "all surveys are returned with answers and discussion (temporary, need to scope to active only)" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, survey2} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer1} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)
      {:ok, discussion1} = Surveys.add_discussion_to_answer(answer1.id, %{content: "Discuss"}, user: user)
      {:ok, answer2} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"}, user: user)

      surveys = Surveys.get_available_surveys()
      assert length(surveys) == 2

      assert Enum.at(surveys, 0).id == survey.id
      assert Enum.at(surveys, 1).id == survey2.id
      assert Enum.at(surveys, 0).answers |> Enum.map(& &1.id) == [answer1.id, answer2.id]
      assert Enum.at(surveys, 1).answers == []
      assert surveys |> Enum.at(0) |> Map.get(:answers) |> Enum.at(0) |> Map.get(:discussions) == [discussion1]
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

    test "a user can cast a vote for a discussion" do
      {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
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
end
