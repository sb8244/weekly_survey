defmodule WeeklySurvey.Surveys.Discussion do
  use Ecto.Schema
  import Ecto.Changeset

  alias WeeklySurvey.Surveys.{Answer, Vote}
  alias WeeklySurvey.Users.User

  schema "discussions" do
    field :content, :string
    belongs_to :answer, Answer
    belongs_to :user, User
    has_many :votes, {"discussions_votes", Vote}, foreign_key: :voteable_id

    timestamps()
  end

  @doc false
  def changeset(discussion, attrs) do
    discussion
    |> cast(attrs, [:content, :answer_id, :user_id])
    |> validate_required([:content, :answer_id, :user_id])
    |> foreign_key_constraint(:answer_id)
    |> foreign_key_constraint(:user_id)
  end
end
