defmodule WeeklySurvey.Repo.Migrations.ChangeActiveUntilToDateTime do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      modify :active_until, :utc_datetime, null: false
    end
  end
end
