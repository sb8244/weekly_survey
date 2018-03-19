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
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"})
      assert answer.id
      assert answer.survey_id == survey.id
      assert answer.answer == "Answer"
    end

    test "a survey_id can be used" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"})
      assert answer.id
      assert answer.survey_id == survey.id
    end

    test "an invalid survey_id is an error" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:error, changeset} = Surveys.add_answer_to_survey(survey.id + 1, %{answer: "Answer"})
      assert changeset.errors |> Keyword.keys == [:survey_id]
    end
  end

  describe "add_discussion_to_answer/2" do
    test "a valid discussion is added to an answer" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"})
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer, %{content: "Discuss"})
      assert discussion.id
      assert discussion.answer_id == answer.id
      assert discussion.content == "Discuss"
    end

    test "a valid discussion is added to an answer by id" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "Answer"})
      {:ok, discussion} = Surveys.add_discussion_to_answer(answer.id, %{content: "Discuss"})
      assert discussion.id
      assert discussion.answer_id == answer.id
    end
  end

  describe "get_available_surveys/0" do
    test "all surveys are returned with answers and discussion (temporary, need to scope to active only)" do
      {:ok, survey} = Surveys.create_survey(@valid_survey_params)
      {:ok, survey2} = Surveys.create_survey(@valid_survey_params)
      {:ok, answer1} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"})
      {:ok, discussion1} = Surveys.add_discussion_to_answer(answer1.id, %{content: "Discuss"})
      {:ok, answer2} = Surveys.add_answer_to_survey(survey.id, %{answer: "Answer"})

      surveys = Surveys.get_available_surveys()
      assert length(surveys) == 2

      assert Enum.at(surveys, 0).id == survey.id
      assert Enum.at(surveys, 1).id == survey2.id
      assert Enum.at(surveys, 0).answers |> Enum.map(& &1.id) == [answer1.id, answer2.id]
      assert Enum.at(surveys, 1).answers == []
      assert surveys |> Enum.at(0) |> Map.get(:answers) |> Enum.at(0) |> Map.get(:discussions) == [discussion1]
    end
  end
end
