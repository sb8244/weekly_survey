defmodule WeeklySurvey.Surveys.Survey do
  @enforce_keys [:id, :name, :question, :answers]
  defstruct @enforce_keys
end
