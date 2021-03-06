defmodule WeeklySurveyWeb.ConnCase do
  @moduledoc """
  This module defines the test case to be used by
  tests that require setting up a connection.

  Such tests rely on `Phoenix.ConnTest` and also
  import other functionality to make it easier
  to build common datastructures and query the data layer.

  Finally, if the test case interacts with the database,
  it cannot be async. For this reason, every test runs
  inside a transaction which is reset at the beginning
  of the test unless the test case is marked as async.
  """

  use ExUnit.CaseTemplate

  using do
    quote do
      # Import conveniences for testing with connections
      use Phoenix.ConnTest
      import WeeklySurveyWeb.Router.Helpers

      # The default endpoint for testing
      @endpoint WeeklySurveyWeb.Endpoint
    end
  end


  setup tags do
    conn = Phoenix.ConnTest.build_conn()
    {:ok, conn: conn, session_conn: session_conn(conn)}
  end

  def session_conn(conn) do
    opts =
      Plug.Session.init(
        store: :cookie,
        key: "_weekly_survey_key",
        signing_salt: WeeklySurveyWeb.Endpoint.signing_salt(),
        log: false,
        encrypt: false
      )
    conn
    |> Plug.Session.call(opts)
    |> Plug.Conn.fetch_session()
  end
end
