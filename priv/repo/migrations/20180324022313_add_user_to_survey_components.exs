defmodule WeeklySurvey.Repo.Migrations.AddUserToSurveyComponents do
  use Ecto.Migration

  def change do
    alter table(:discussions) do
      add :user_id, references(:users), null: false
    end

    alter table(:answers) do
      add :user_id, references(:users), null: false
    end
  end
end
