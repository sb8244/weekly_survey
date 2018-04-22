# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

# General application configuration
config :weekly_survey,
  ecto_repos: [WeeklySurvey.Repo]

# Configures the endpoint
config :weekly_survey, WeeklySurveyWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Gh6f+qj5QZflEcDcTFF+5q3MxrSxW63uN9G17M7jWdxXw15tyOIBQIQxFebsKEcX",
  render_errors: [view: WeeklySurveyWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WeeklySurvey.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :weekly_survey, WeeklySurvey.Users.EncryptedGuid,
  secret: "local secret"

# AppSignal begin

config :weekly_survey, WeeklySurveyWeb.Endpoint,
  instrumenters: [Appsignal.Phoenix.Instrumenter]

config :phoenix, :template_engines,
  eex: Appsignal.Phoenix.Template.EExEngine,
  exs: Appsignal.Phoenix.Template.ExsEngine

config :weekly_survey, WeeklySurvey.Repo,
  loggers: [Appsignal.Ecto, Ecto.LogEntry]

# AppSignal end

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
