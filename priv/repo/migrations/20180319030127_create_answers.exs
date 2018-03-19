defmodule WeeklySurvey.Repo.Migrations.CreateAnswers do
  use Ecto.Migration

  def change do
    create table(:answers) do
      add :answer, :string, null: false
      add :survey_id, references(:surveys), null: false

      timestamps()
    end

  end
end
