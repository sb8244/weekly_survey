defmodule WeeklySurvey.Surveys.Survey do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.Answer

  schema "surveys" do
    field :name, :string
    field :question, :string
    field :has_answer_vote, :boolean, virtual: true
    field :active_until, :naive_datetime
    has_many :answers, Answer

    timestamps()
  end

  @doc false
  def changeset(survey, attrs) do
    attrs = default_active_until(attrs)

    survey
    |> cast(attrs, [:name, :question, :active_until])
    |> validate_required([:name, :question, :active_until])
  end

  defp default_active_until(attrs = %{active_until: _}), do: attrs
  defp default_active_until(attrs) do
    Map.put(attrs, :active_until, Utils.Time.days_from_now(7))
  end
end
