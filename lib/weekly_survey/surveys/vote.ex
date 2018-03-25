defmodule WeeklySurvey.Surveys.Vote do
  defmodule Guards do
    alias WeeklySurvey.Surveys.{Answer, Discussion}

    defguard is_voteable(struct) when struct == Answer or struct == Discussion
  end

  use Ecto.Schema

  schema "abstract table: votes" do
    field :voteable_id, :integer
    field :user_id, :id

    timestamps()
  end
end
