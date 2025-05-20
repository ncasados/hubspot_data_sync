import Config

config :hubspot_data_sync, Oban,
  engine: Oban.Engines.Basic,
  notifier: Oban.Notifiers.Postgres,
  queues: [default: 10],
  repo: HubspotDataSync.Repo

config :hubspot_data_sync, HubspotDataSync.Repo,
  database: "hubspot_data_sync",
  username: "postgres",
  password: "postgres",
  hostname: "localhost"

config :hubspot_data_sync,
  ecto_repos: [HubspotDataSync.Repo]

config :hubspot_data_sync,
  hubspot_token: System.get_env("HUBSPOT_TOKEN")

import_config("#{config_env()}.exs")
