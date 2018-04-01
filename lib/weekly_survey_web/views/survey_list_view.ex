defmodule WeeklySurveyWeb.SurveyListView do
  use WeeklySurveyWeb, :view

  def user_name(user) do
    info = Map.get(user, :user_info) || %{}
    Map.get(info, :name, "unknown")
  end
end
