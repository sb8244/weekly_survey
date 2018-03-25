defmodule WeeklySurveyWeb.SurveyListControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  @valid_survey_params %{name: "Test", question: "A question?"}

  test "HTML is rendered", %{conn: conn} do
    html =
      conn
        |> get("/")
        |> html_response(200)

    assert html =~ "<h2>Available Surveys</h2>"
  end

  test "a survey, answers, and discussions are all rendererd", %{conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    {:ok, survey} = Surveys.create_survey(@valid_survey_params)
    {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
    {:ok, answer2} = Surveys.add_answer_to_survey(survey, %{answer: "B Answer"}, user: user)
    {:ok, discussion1} = Surveys.add_discussion_to_answer(answer, %{content: "A Discuss"}, user: user)
    {:ok, discussion2} = Surveys.add_discussion_to_answer(answer, %{content: "B Discuss"}, user: user)

    html =
      conn
        |> get("/")
        |> html_response(200)

    assert html =~ answer.answer
    assert html =~ answer2.answer
    assert html =~ discussion1.content
    assert html =~ discussion2.content
  end

  test "the user answer vote is shown on the screen and the other answer vote options are removed", %{session_conn: conn} do
    {:ok, user} = WeeklySurvey.Users.find_or_create_user(UUID.uuid4())
    {:ok, survey} = Surveys.create_survey(@valid_survey_params)
    {:ok, answer} = Surveys.add_answer_to_survey(survey, %{answer: "A Answer"}, user: user)
    {:ok, _} = Surveys.cast_vote(answer, user: user)

    html =
      conn
        |> put_session(:user_guid, user.guid)
        |> get("/")
        |> html_response(200)

    assert html =~ ~s(<span class="voted-badge" data-answer-id="#{answer.id}">Voted!</span>)
    refute html =~ ~s(>Vote</a>)
  end
end
