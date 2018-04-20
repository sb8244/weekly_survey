defmodule WeeklySurveyWeb.Admin.SurveyListController do
  use WeeklySurveyWeb, :controller

  alias WeeklySurvey.Surveys

  plug WeeklySurvey.Users.AuthenticationPlug, [required: false]

  def index(conn, _params) do
    conn
      |> assign(:surveys, get_surveys())
      |> assign(:active_until, Utils.Time.days_from_now(7) |> Map.put(:second, 0))
      |> render("index.html")
  end

  def create(conn, params) do
    handle_ecto_operation(&create_survey/1, [conn: conn, params: creation_params(params)], error_reason: "Your survey was not added")
      |> redirect(to: admin_survey_list_path(conn, :index))
  end

  def update(conn, params) do
    handle_ecto_operation(&update_survey/1, [conn: conn, params: update_params(params), id: params["id"]], error_reason: "Your survey was not updated")
      |> redirect(to: admin_survey_list_path(conn, :index))
  end

  defp get_surveys() do
    WeeklySurvey.Surveys.admin_get_survey_list()
  end

  defp create_survey(conn: _, params: params) do
    Surveys.create_survey(params)
  end

  defp update_survey(conn: _, params: params, id: id) do
    Surveys.update_survey(id, params)
  end

  defp creation_params(params) do
    allowed_params = %{}

    allowed_params =
      case Map.get(params, "question") do
        nil -> allowed_params
        question -> Map.merge(allowed_params, %{name: question, question: question})
      end

    allowed_params =
      case Map.get(params, "active_until") do
        nil -> allowed_params
        date -> Map.merge(allowed_params, %{active_until: date})
      end

    allowed_params
  end

  defp update_params(params), do: creation_params(params)
end
