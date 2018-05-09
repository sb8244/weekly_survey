defmodule WeeklySurvey.Repo.Migrations.MigrateContentToTextType do
  use Ecto.Migration

  def up do
    alter table(:discussions) do
      modify :content, :text, null: false
    end

    alter table(:answers) do
      modify :answer, :text, null: false
    end
  end

  def down do
    alter table(:discussions) do
      modify :content, :string, null: false
    end

    alter table(:answers) do
      modify :answer, :string, null: false
    end
  end
end
