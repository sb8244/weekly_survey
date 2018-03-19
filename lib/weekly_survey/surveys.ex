defmodule WeeklySurvey.Surveys do
  alias WeeklySurvey.Surveys.Survey
  alias WeeklySurvey.Surveys.Answer
  alias WeeklySurvey.Surveys.Discussion

  alias WeeklySurvey.Repo
  import Ecto.Query

  def create_survey(params = %{}) do
    Survey.changeset(%Survey{}, params)
      |> Repo.insert()
  end

  def add_answer_to_survey(survey = %Survey{}, params = %{}) do
    add_answer_to_survey(survey.id, params)
  end

  def add_answer_to_survey(survey_id, params = %{}) when is_number(survey_id) do
    Answer.changeset(%Answer{}, Map.merge(params, %{survey_id: survey_id}))
      |> Repo.insert()
  end

  def add_discussion_to_answer(answer = %Answer{}, params = %{}) do
    add_discussion_to_answer(answer.id, params)
  end

  def add_discussion_to_answer(answer_id, params = %{}) when is_number(answer_id) do
    Discussion.changeset(%Discussion{}, Map.merge(params, %{answer_id: answer_id}))
      |> Repo.insert()
  end

  def get_available_surveys() do
    discussion_preloading_query =
      from d in Discussion,
      order_by: [asc: :id]

    answers_preloading_query =
      from a in Answer,
      order_by: [asc: :id],
      preload: [discussions: ^discussion_preloading_query]

    query =
      from s in Survey,
      order_by: [asc: :id],
      preload: [answers: ^answers_preloading_query]

    Repo.all(query)
  end
end
