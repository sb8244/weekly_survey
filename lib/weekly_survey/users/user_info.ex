defmodule WeeklySurvey.Users.UserInfo do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Users.User

  schema "user_infos" do
    field :name, :string
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(user_info, attrs) do
    user_info
    |> cast(attrs, [:name, :user_id])
    |> validate_required([:name, :user_id])
    |> foreign_key_constraint(:user_id)
    |> unique_constraint(:user_id)
  end
end
