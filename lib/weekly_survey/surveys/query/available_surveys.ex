defmodule WeeklySurvey.Surveys.Query.AvailableSurveys do
  import Ecto.Query
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Surveys.{Answer, Discussion, Survey}

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
