defmodule WeeklySurveyWeb.Admin.SurveyListControllerTest do
  use WeeklySurveyWeb.ConnCase
  use WeeklySurvey.DataCase, no_checkout: true, async: true

  alias WeeklySurvey.Surveys

  def valid_survey_params(params = %{}) do
    %{name: "Test", question: "A question?"}
      |> Map.merge(params)
  end

  describe "GET /admin" do
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

  describe "POST /admin/surveys" do
    test "a valid survey is created", %{conn: conn} do
      response =
        conn
          |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
          |> post("/admin/surveys", %{question: "Test?"})

      assert redirected_to(response, 302) == "/admin"
      assert get_flash(response, :error) == nil

      survey = Repo.one!(from x in WeeklySurvey.Surveys.Survey, order_by: [desc: x.id], limit: 1)
      assert survey.name == "Test?"
      assert survey.question == survey.name
    end

    test "invalid params are an error", %{conn: conn} do
      response =
        conn
          |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
          |> post("/admin/surveys", %{question: " "})

      assert redirected_to(response, 302) == "/admin"
      assert get_flash(response, :error) == "Your survey was not added: question can't be blank"
    end
  end

  describe "PUT /admin/surveys/:id" do
    test "a survey can be updated", %{conn: conn} do
      {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
      response =
        conn
          |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
          |> put("/admin/surveys/#{survey.id}", %{question: "Test?", name: "ignored"})

      assert redirected_to(response, 302) == "/admin"
      assert get_flash(response, :error) == nil

      survey = Repo.get!(WeeklySurvey.Surveys.Survey, survey.id)
      assert survey.question == "Test?"
      assert survey.name == "Test?"
    end

    test "an invalid change is an error", %{conn: conn} do
      {:ok, survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
      response =
        conn
          |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
          |> put("/admin/surveys/#{survey.id}", %{question: ""})

      assert redirected_to(response, 302) == "/admin"
      assert get_flash(response, :error) == "Your survey was not updated: question can't be blank"
    end

    test "an invalid id is an error", %{conn: conn} do
      {:ok, _survey} = Surveys.create_survey(valid_survey_params(%{question: "One"}))
      response =
        conn
          |> Plug.Conn.put_private(:basic_auth_skip_admin, true)
          |> put("/admin/surveys/0", %{question: "valid"})

      assert redirected_to(response, 302) == "/admin"
      assert get_flash(response, :error) == "Not found"
    end
  end
end
