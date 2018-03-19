defmodule WeeklySurvey.Surveys.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.Survey
  alias WeeklySurvey.Surveys.Discussion

  schema "answers" do
    field :answer, :string
    belongs_to :survey, Survey
    has_many :discussions, Discussion

    timestamps()
  end

  @doc false
  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:answer, :survey_id])
    |> validate_required([:answer, :survey_id])
    |> foreign_key_constraint(:survey_id)
  end
end