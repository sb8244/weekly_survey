defmodule WeeklySurvey.Surveys.Query.AdminSurveyList do
  import Ecto.Query
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Surveys.{Answer, Discussion, Survey}

  def get_all() do
    query =
      from s in Survey,
      where: fragment("?::timestamp", s.active_until) > ^Utils.Time.days_from_now(-90),
      order_by: [desc: :id],
      preload: [answers: ^preload_for_display_query()]

    Repo.all(query)
      |> add_vote_counts()
  end

  defp preload_for_display_query() do
    discussion_preloading_query =
      from d in Discussion,
      order_by: [asc: :id],
      preload: [votes: [user: :user_info], user: [:user_info]]

    from a in Answer,
      order_by: [asc: :id],
      preload: [discussions: ^discussion_preloading_query, votes: [user: [:user_info]]]
  end

  defp add_vote_counts(surveys) do
    Enum.map(surveys, fn survey = %{answers: answers} ->
      new_answers =
        answers
          |> Enum.map(fn answer = %{votes: votes} ->
            vote_count = length(votes)
            Map.put(answer, :vote_count, vote_count)
          end)
          |> Enum.sort_by(& &1.vote_count)
          |> Enum.reverse()

      Map.put(survey, :answers, new_answers)
    end)
  end
end
