defmodule WeeklySurvey.Surveys.Vote do
  defmodule Guards do
    alias WeeklySurvey.Surveys.{Answer, Discussion}

    defguard is_voteable(struct) when struct == Answer or struct == Discussion
    defguard is_voteable_string(str) when str == "answer" or str == "discussion"
  end

  alias WeeklySurvey.Surveys.{Answer, Discussion}

  use Ecto.Schema

  def get_voteable_module("answer"), do: Answer
  def get_voteable_module("discussion"), do: Discussion

  schema "abstract table: votes" do
    field :voteable_id, :integer
    field :user_id, :id

    timestamps()
  end
end