defmodule WeeklySurvey.Surveys.Vote do
  defmodule Guards do
    alias WeeklySurvey.Surveys.{Answer, Discussion}

    defguard is_voteable(struct) when struct == Answer or struct == Discussion
    defguard is_voteable_string(str) when str == "answer" or str == "discussion"
  end

  alias WeeklySurvey.Surveys.{Answer, Discussion}
  alias WeeklySurvey.Users.User

  use Ecto.Schema

  def get_voteable_module("answer"), do: Answer
  def get_voteable_module("discussion"), do: Discussion
  def get_voteable_table("answer"), do: "answers_votes"
  def get_voteable_table("discussion"), do: "discussions_votes"

  schema "abstract table: votes" do
    field :voteable_id, :integer
    belongs_to :user, User

    timestamps()
  end
end
