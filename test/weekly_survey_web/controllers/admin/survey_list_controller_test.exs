defmodule WeeklySurveyWeb.Admin.SurveyListControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  def valid_survey_params(params = %{}) do
    %{name: "Test", question: "A question?"}
      |> Map.merge(params)
  end

  test "all surveys are rendered", %{conn: conn} do
    {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
    {:ok, survey2} = Surveys.create_survey(valid_survey_params(%{question: "Two"}))
    {:ok, expired_survey} = Surveys.create_survey(valid_survey_params(%{active_until: Utils.Time.seconds_from_now(-1), question: "Three"}))

    html =
      conn
        |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
        |> get("/admin")
        |> html_response(200)

    assert html =~ "<h2>Survey Administration</h2>"
    assert html =~ survey.question
    assert html =~ survey2.question
    assert html =~ expired_survey.question
  end

  test "vote counts are included with each answer, sorted by the vote count", %{conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    {:ok, user2} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    {:ok, user3} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())

    {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
    {:ok, _answer} = Surveys.add_answer_to_survey(survey, %{answer: "One"}, user: user)
    {:ok, answer2} = Surveys.add_answer_to_survey(survey, %{answer: "Two"}, user: user)
    {:ok, answer3} = Surveys.add_answer_to_survey(survey, %{answer: "Three"}, user: user)
    {:ok, _} = Surveys.cast_vote(answer3, user: user)
    {:ok, _} = Surveys.cast_vote(answer3, user: user2)
    {:ok, _} = Surveys.cast_vote(answer2, user: user3)

    html =
      conn
        |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
        |> get("/admin")
        |> html_response(200)

    assert html =~ "(2) Three"
    assert html =~ "(1) Two"
    assert html =~ "(0) One"

    first_occurs_at = :binary.match(html, "(0) One") |> elem(0)
    second_occurs_at = :binary.match(html, "(1) Two") |> elem(0)
    third_occurs_at = :binary.match(html, "(2) Three") |> elem(0)
    assert Enum.sort([first_occurs_at, second_occurs_at, third_occurs_at]) == [third_occurs_at, second_occurs_at, first_occurs_at]
  end
end
