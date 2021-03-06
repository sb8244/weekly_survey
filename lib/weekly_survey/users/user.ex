defmodule WeeklySurvey.Users.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Users.UserInfo

  schema "users" do
    field :guid, Ecto.UUID
    has_one :user_info, UserInfo

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
