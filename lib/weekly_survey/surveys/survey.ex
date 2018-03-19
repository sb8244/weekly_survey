defmodule WeeklySurvey.Surveys.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.Answer

  schema "surveys" do
    field :name, :string
    field :question, :string
    has_many :answers, Answer

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:name, :question])
    |> validate_required([:name, :question])
  end
end
