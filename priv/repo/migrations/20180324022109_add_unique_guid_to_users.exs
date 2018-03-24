defmodule WeeklySurvey.Repo.Migrations.AddUniqueGuidToUsers do
  use Ecto.Migration

  def change do
    create unique_index("users", [:guid])
  end
end
