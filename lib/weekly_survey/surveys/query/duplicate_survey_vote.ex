defmodule WeeklySurvey.Surveys.Query.DuplicateSurveyVote do
  import Ecto.Query

  alias WeeklySurvey.Repo
  alias WeeklySurvey.Surveys.{Answer, Vote}

  def vote_exists?(%Answer{id: id, survey_id: survey_id}) do
    query =
      from v in {"answers_votes", Vote},
        join: a in Answer, where: v.voteable_id == a.id,
        where: a.survey_id == ^survey_id,
        where: a.id != ^id

    Repo.aggregate(query, :count, :id) > 0
  end
end
