defmodule WeeklySurveyWeb.Admin.SurveyListView do
  use WeeklySurveyWeb, :view

  def user_name(user) do
    info = Map.get(user, :user_info) || %{}
    Map.get(info, :name, "unknown")
  end

  def survey_active?(survey) do
    NaiveDateTime.compare(survey.active_until, Utils.Time.now()) == :gt
  end
end
