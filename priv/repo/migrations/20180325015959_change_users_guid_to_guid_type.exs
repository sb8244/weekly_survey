defmodule WeeklySurvey.Repo.Migrations.ChangeUsersGuidToGuidType do
  use Ecto.Migration

  def change do
    alter table(:users) do
      remove :guid
      add :guid, :uuid, null: false
    end
  end
end
