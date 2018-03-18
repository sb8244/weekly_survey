defmodule WeeklySurvey.Surveys.Answer do
  @enforce_keys [:id, :answer, :votes, :discussions]
  defstruct @enforce_keys
end
