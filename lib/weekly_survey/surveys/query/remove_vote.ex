defmodule WeeklySurvey.Surveys.Query.RemoveVote do
  import Ecto.Query
  alias WeeklySurvey.Repo
  alias WeeklySurvey.Surveys.Vote

  def remove_vote(voteable_type, vote_id, user: user) do
    query =
      from(
        v in {Vote.get_voteable_table(voteable_type), Vote},
        where: v.id == ^vote_id,
        where: v.user_id == ^user.id
      )

    Repo.delete_all(query)
      |> elem(0)
  end
end
