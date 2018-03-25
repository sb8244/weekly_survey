defmodule WeeklySurvey.Surveys.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.{Discussion, Survey, Vote}
  alias WeeklySurvey.Users.User

  schema "answers" do
    field :answer, :string
    belongs_to :survey, Survey
    has_many :discussions, Discussion
    belongs_to :user, User
    has_many :votes, {"answers_votes", Vote}, foreign_key: :voteable_id

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:answer, :survey_id, :user_id])
    |> validate_required([:answer, :survey_id, :user_id])
    |> foreign_key_constraint(:survey_id)
    |> foreign_key_constraint(:user_id)
  end
end
