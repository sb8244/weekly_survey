defmodule WeeklySurvey.Repo.Migrations.AddActiveUntilToSurveys do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      add :active_until, :date, null: true
    end
  end
end
