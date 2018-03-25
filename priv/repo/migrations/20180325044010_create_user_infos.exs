defmodule WeeklySurvey.Repo.Migrations.CreateUserInfos do
  use Ecto.Migration

  def change do
    create table(:user_infos) do
      add :name, :string, null: false
      add :user_id, references(:users), null: false

      timestamps()
    end

    create unique_index("user_infos", [:user_id])
  end
end
