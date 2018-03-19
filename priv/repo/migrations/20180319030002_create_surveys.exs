defmodule WeeklySurvey.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys) do
      add :name, :string, null: false
      add :question, :string, null: false

      timestamps()
    end

  end
end
