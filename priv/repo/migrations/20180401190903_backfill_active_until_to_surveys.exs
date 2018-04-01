defmodule WeeklySurvey.Repo.Migrations.BackfillActiveUntilToSurveys do
  use Ecto.Migration

  def change do
    # WeeklySurvey.Repo.update_all(WeeklySurvey.Surveys.Survey, set: [active_until: Ecto.DateTime.utc])

    alter table(:surveys) do
      modify :active_until, :date, null: false
    end
  end
end
