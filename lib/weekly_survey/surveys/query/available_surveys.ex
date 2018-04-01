defmodule WeeklySurvey.Surveys.Query.AvailableSurveys do
  import Ecto.Query
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Surveys.{Answer, Discussion, Survey, Vote}

  def get_available_surveys(user: user) do
    discussion_preloading_query =
      from d in Discussion,
      order_by: [asc: :id],
      preload: [:votes]

    answers_votes_preloads =
      if user != nil do
        from v in {"answers_votes", Vote},
          where: v.user_id == ^user.id
      else
        from v in {"answers_votes", Vote},
          where: 1 == 0
      end

    answers_preloading_query =
      from a in Answer,
      order_by: [asc: :id],
      preload: [discussions: ^discussion_preloading_query, votes: ^answers_votes_preloads]

    query =
      from s in Survey,
      order_by: [desc: :id],
      preload: [answers: ^answers_preloading_query]

    Repo.all(query)
  end
end
