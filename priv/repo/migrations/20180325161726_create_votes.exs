defmodule WeeklySurvey.Repo.Migrations.CreateVotes do
  use Ecto.Migration

  def change do
    create table(:answers_votes) do
      add :voteable_id, :integer, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create table(:discussions_votes) do
      add :voteable_id, :integer, null: false
      add :user_id, references(:users, on_delete: :nothing), null: false

      timestamps()
    end

    create unique_index("answers_votes", [:user_id, :voteable_id])
    create unique_index("discussions_votes", [:user_id, :voteable_id])
  end
end
