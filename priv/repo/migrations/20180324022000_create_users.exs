defmodule WeeklySurvey.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :guid, :string, null: false

      timestamps()
    end

  end
end
