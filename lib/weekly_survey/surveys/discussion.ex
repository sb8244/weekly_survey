defmodule WeeklySurvey.Surveys.Discussion do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.Answer

  schema "discussions" do
    field :content, :string
    belongs_to :answer, Answer

    timestamps()
  end

  @doc false
  def changeset(discussion, attrs) do
    discussion
    |> cast(attrs, [:content, :answer_id])
    |> validate_required([:content, :answer_id])
    |> foreign_key_constraint(:answer_id)
  end
end
