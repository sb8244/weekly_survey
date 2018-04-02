defmodule WeeklySurvey.Surveys do
  alias WeeklySurvey.Surveys.{Answer, Discussion, Query.AdminSurveyList, Query.AvailableSurveys, Query.RemoveVote, Survey, Vote}
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Users.User

  import Vote.Guards

  def get_available_surveys(user: user) do
    AvailableSurveys.get_available_surveys(user: user)
  end

  def admin_get_survey_list() do
    AdminSurveyList.get_all()
  end

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
    with %User{user_info: info} when not is_nil(info) <- Repo.preload(user, :user_info),
         changeset <- Discussion.changeset(%Discussion{}, Map.merge(params, %{answer_id: answer_id, user_id: user.id})) do
           Repo.insert(changeset)
         else
           %User{user_info: nil} -> {:error, :no_info}
         end
  end

  def cast_vote(voteable = %{__struct__: struct}, user: user) when is_voteable(struct) do
    duplicate_survey_vote =
      if struct == Answer do
        WeeklySurvey.Surveys.Query.DuplicateSurveyVote.vote_exists?(voteable, user: user)
      else
        false
      end

    if duplicate_survey_vote do
      {:error, :duplicate_vote}
    else
      Ecto.build_assoc(voteable, :votes, user_id: user.id)
        |> Repo.insert(on_conflict: :nothing)
    end
  end

  def remove_vote(voteable_type, vote_id, user: user) do
    RemoveVote.remove_vote(voteable_type, vote_id, user: user)
      |> case do
        removed_count when removed_count >= 1 -> :ok
        0 -> {:error, :not_found}
      end
  end

  def get_voteable(voteable_type, voteable_id) when is_voteable_string(voteable_type) do
    case Repo.get(Vote.get_voteable_module(voteable_type), voteable_id) do
      nil -> {:error, :not_found}
      voteable -> {:ok, voteable}
    end
  end

  def get_voteable(_type, _id) do
    {:error, :invalid_type}
  end
end
