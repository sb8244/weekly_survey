defmodule WeeklySurvey.Repo.Migrations.CreateDiscussions do
  use Ecto.Migration

  def change do
    create table(:discussions) do
      add :content, :string, null: false
      add :answer_id, references(:answers), null: false

      timestamps()
    end

  end
end
