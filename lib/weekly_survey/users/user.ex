defmodule WeeklySurvey.Users.User do
  use Ecto.Schema
  import Ecto.Changeset


  schema "users" do
    field :guid, :string

    timestamps()
  end

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, [:guid])
    |> validate_required([:guid])
    |> unique_constraint(:guid)
  end
end
