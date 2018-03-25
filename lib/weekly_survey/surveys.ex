defmodule WeeklySurvey.Surveys do
  alias WeeklySurvey.Surveys.{Answer, Discussion, Query.AvailableSurveys, Survey, Vote}
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Users.User

  import Vote.Guards

  def create_survey(params = %{}) do
    Survey.changeset(%Survey{}, params)
      |> Repo.insert()
  end

  def add_answer_to_survey(survey = %Survey{}, params, user: user) do
    add_answer_to_survey(survey.id, params, user: user)
  end

  def add_answer_to_survey(survey_id, params = %{}, user: user = %User{}) when is_number(survey_id) do
    Answer.changeset(%Answer{}, Map.merge(params, %{survey_id: survey_id, user_id: user.id}))
      |> Repo.insert()
  end

  def add_discussion_to_answer(answer = %Answer{}, params, user: user) do
    add_discussion_to_answer(answer.id, params, user: user)
  end

  def add_discussion_to_answer(answer_id, params = %{}, user: user = %User{}) when is_number(answer_id) do
    Discussion.changeset(%Discussion{}, Map.merge(params, %{answer_id: answer_id, user_id: user.id}))
      |> Repo.insert()
  end

  def get_available_surveys() do
    AvailableSurveys.get_available_surveys()
  end

  def cast_vote(voteable = %{__struct__: struct}, user: user) when is_voteable(struct) do
    Ecto.build_assoc(voteable, :votes, user_id: user.id)
      |> Repo.insert(on_conflict: :nothing)
  end
end
